import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// One label and how sure the model is about it.
class Prediction {
  const Prediction(this.label, this.confidence);

  final String label;
  final double confidence; // 0.0 to 1.0

  /// "87.4%" — the one place the percentage is formatted, so every screen
  /// that shows a confidence shows it the same way.
  String get percent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// A failure the user is allowed to see. [message] is the sentence to put on
/// screen; [detail] is the technical part, shown underneath for debugging.
class ClassifierException implements Exception {
  const ClassifierException(this.message, {this.detail});

  final String message;
  final String? detail;

  @override
  String toString() => detail == null ? message : '$message ($detail)';
}

/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle']. Pure, so it is unit-testable.
List<String> parseLabels(String raw) => [
  for (final line in raw.split('\n'))
    if (line.trim().isNotEmpty)
      line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
];

class Classifier {
  Classifier._(this._interpreter, this.labels);

  /// Both paths exactly as declared under `assets:` in pubspec.yaml.
  static const modelAsset = 'assets/model/model_unquant.tflite';
  static const labelsAsset = 'assets/model/labels.txt';

  /// Teachable Machine trains on square 224x224 images.
  static const inputSize = 224;

  final Interpreter _interpreter;
  final List<String> labels;

  /// How long the last [classify] call took. Measured because inference runs
  /// on the UI thread, so this number is what the user waits through.
  Duration? lastInference;

  /// Reads the model and the labels once and allocates the tensors. Slow, so
  /// it happens one time at start-up and never per picture.
  static Future<Classifier> load() async {
    final Interpreter interpreter;
    try {
      interpreter = await Interpreter.fromAsset(modelAsset);
    } catch (e) {
      throw ClassifierException(
        'The model file could not be loaded.',
        detail:
            'Expected $modelAsset, listed under "assets:" in pubspec.yaml. $e',
      );
    }

    final List<String> labels;
    try {
      labels = parseLabels(await rootBundle.loadString(labelsAsset));
    } catch (e) {
      interpreter.close();
      throw ClassifierException(
        'The labels file could not be loaded.',
        detail:
            'Expected $labelsAsset, listed under "assets:" in pubspec.yaml. $e',
      );
    }

    if (labels.isEmpty) {
      interpreter.close();
      throw const ClassifierException(
        'The labels file is empty.',
        detail: 'Expected one "index name" line per class in $labelsAsset.',
      );
    }

    return Classifier._(interpreter, labels);
  }

  /// Image bytes in, one [Prediction] per label out, highest confidence first.
  List<Prediction> classify(Uint8List bytes) {
    final watch = Stopwatch()..start();

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ClassifierException(
        'That file is not an image we can read.',
        detail: 'Pick a JPEG or PNG picture.',
      );
    }

    // Same crop as training: centre square, 224x224, with the EXIF rotation
    // baked in so a portrait photo is not classified sideways.
    final square = img.copyResizeCropSquare(
      img.bakeOrientation(decoded),
      size: inputSize,
    );

    // Shape [1, 224, 224, 3], every channel a float from -1 to 1.
    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        }),
      ),
    ];

    // Shape [1, classes]. The model ends in a softmax, so these add up to 1.
    final output = [List<double>.filled(labels.length, 0)];

    try {
      _interpreter.run(input, output);
    } catch (e) {
      throw ClassifierException(
        'The model could not read that image.',
        detail:
            'The model expects ${inputSize}x$inputSize pixels and '
            '${labels.length} classes, matching $labelsAsset. $e',
      );
    }

    // Index i of the output belongs to line i of the labels: pair first, then
    // sort. Sorting the raw numbers first makes every label wrong.
    final predictions = [
      for (var i = 0; i < labels.length; i++)
        Prediction(labels[i], output.first[i]),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));

    lastInference = (watch..stop()).elapsed;
    return predictions;
  }

  /// Convenience for the T10 smoke test: classify a bundled asset.
  Future<List<Prediction>> classifyAsset(String assetPath) async {
    final ByteData data;
    try {
      data = await rootBundle.load(assetPath);
    } catch (e) {
      throw ClassifierException(
        'The asset $assetPath is not in the app.',
        detail:
            'Put the file in assets/model/ — the folder is already declared '
            'under "assets:" in pubspec.yaml, so it is bundled on the next '
            'build. $e',
      );
    }
    return classify(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void close() => _interpreter.close();
}
