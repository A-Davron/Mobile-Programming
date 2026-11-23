import 'package:flutter/material.dart';

import '../services/classifier.dart';

/// Temporary Part 3 page. It proves the classifier works end to end before any
/// real screens exist: it classifies the bundled sample image, prints every
/// label with its percentage to the console, and lets you feed it a text file
/// to check that bad input ends in a message rather than a crash.
///
/// Since Part 4 it is reachable from the Model screen ("Run the smoke test"),
/// so T10 and T12 can still be demonstrated.
class SmokeTestPage extends StatefulWidget {
  const SmokeTestPage({super.key, required this.classifier});

  /// The one instance loaded in main. This screen never calls
  /// Classifier.load() itself.
  final Classifier classifier;

  @override
  State<SmokeTestPage> createState() => _SmokeTestPageState();
}

class _SmokeTestPageState extends State<SmokeTestPage> {
  static const sampleAsset = 'assets/model/sample.jpg';

  List<Prediction>? _predictions;
  String? _errorMessage;
  String? _errorDetail;
  String _source = sampleAsset;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _classifySample();
  }

  Future<void> _classifySample() => _run(sampleAsset, () async {
    return widget.classifier.classifyAsset(sampleAsset);
  });

  /// Feeds the classifier a text file on purpose: labels.txt is not an image,
  /// so this must end in a readable message and never a red screen.
  Future<void> _classifyTextFile() =>
      _run(Classifier.labelsAsset, () async {
        return widget.classifier.classifyAsset(Classifier.labelsAsset);
      });

  Future<void> _run(
    String source,
    Future<List<Prediction>> Function() work,
  ) async {
    setState(() {
      _busy = true;
      _source = source;
      _errorMessage = null;
      _errorDetail = null;
    });

    try {
      final predictions = await work();
      final total = predictions.fold<double>(0, (s, p) => s + p.confidence);

      debugPrint('--- $source ---');
      for (final p in predictions) {
        debugPrint('${p.label.padRight(14)} ${p.percent}');
      }
      debugPrint('sum of confidences: ${total.toStringAsFixed(4)}');
      debugPrint('inference: ${widget.classifier.lastInference?.inMilliseconds} ms');

      if (!mounted) return;
      setState(() {
        _predictions = predictions;
        _busy = false;
      });
    } on ClassifierException catch (e) {
      if (!mounted) return;
      setState(() {
        _predictions = null;
        _errorMessage = e.message;
        _errorDetail = e.detail;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _predictions = null;
        _errorMessage = 'Something went wrong while classifying.';
        _errorDetail = e.toString();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final classifier = widget.classifier;

    return Scaffold(
      appBar: AppBar(title: const Text('Smoke test')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${classifier.labels.length} classes · '
              '${Classifier.inputSize}x${Classifier.inputSize} input',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'source: $_source',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            if (_busy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _ErrorCard(message: _errorMessage!, detail: _errorDetail)
            else if (_predictions != null)
              _PredictionList(
                predictions: _predictions!,
                inference: classifier.lastInference,
              ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _classifySample,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Classify sample.jpg'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _classifyTextFile,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Classify a text file'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionList extends StatelessWidget {
  const _PredictionList({required this.predictions, this.inference});

  final List<Prediction> predictions;
  final Duration? inference;

  @override
  Widget build(BuildContext context) {
    final total = predictions.fold<double>(0, (s, p) => s + p.confidence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, p) in predictions.indexed) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  p.label,
                  style: index == 0
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                p.percent,
                style: index == 0
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: p.confidence.clamp(0, 1)),
          const SizedBox(height: 14),
        ],
        const Divider(),
        Text(
          'confidences add up to ${(total * 100).toStringAsFixed(2)}%'
          '${inference == null ? '' : ' · ${inference!.inMilliseconds} ms'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, this.detail});

  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: 10),
            Text(
              detail!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
