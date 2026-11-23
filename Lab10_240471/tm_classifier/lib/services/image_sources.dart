import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// A source failed in a way the user should hear about. [message] is the
/// sentence to show on screen.
class ImageSourceException implements Exception {
  const ImageSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The three ways a picture gets into the app. Each one only delivers bytes;
/// what happens next (classify → History → Result) is the same for all three
/// and lives in HomeShell. No file path leaves this class.
class ImageSources {
  ImageSources({
    ImagePicker? picker,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  })  : _picker = picker ?? ImagePicker(),
        _client = client ?? http.Client();

  final ImagePicker _picker;
  final http.Client _client;
  final Duration timeout;

  /// The model only looks at 224×224 pixels, so a 12-megapixel photo is
  /// shrunk by the system before it reaches Dart.
  static const _maxWidth = 1024.0;

  /// Null means the user backed out of the camera: not an error.
  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera, 'camera');

  /// Null means the user closed the gallery without choosing: not an error.
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery, 'photo library');

  Future<Uint8List?> _pick(ImageSource source, String what) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: _maxWidth);
      return picked == null ? null : await picked.readAsBytes();
    } on PlatformException catch (e) {
      if (e.code.contains('access_denied') || e.code.contains('permission')) {
        throw ImageSourceException(
          'The app is not allowed to use the $what. Allow it in the phone settings and try again.',
        );
      }
      throw ImageSourceException('The $what could not be opened on this device.');
    }
  }

  /// Downloads a picture. Accepts the answer only when the status is 200 and
  /// the content-type starts with image/. [onProgress] gets 0..1 while the
  /// body arrives, or null when the server does not say how big it is.
  Future<Uint8List> fromUrl(String url, {void Function(double? progress)? onProgress}) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      throw const ImageSourceException(
        'That is not a web address. It should start with https://',
      );
    }

    try {
      final response = await _client.send(http.Request('GET', uri)).timeout(timeout);

      if (response.statusCode != 200) {
        throw ImageSourceException(
          response.statusCode == 404
              ? 'Nothing was found at that address (error 404).'
              : 'The server answered with error ${response.statusCode}.',
        );
      }

      final type = response.headers['content-type'] ?? '';
      if (!type.startsWith('image/')) {
        throw ImageSourceException(
          type.startsWith('text/html')
              ? 'That address is a web page, not a picture. Open the image itself and copy its address.'
              : 'That address is not a picture (it sent "${type.isEmpty ? 'no type' : type}").',
        );
      }

      final total = response.contentLength;
      final bytes = BytesBuilder(copy: false);
      onProgress?.call(total == null || total == 0 ? null : 0);
      await for (final chunk in response.stream.timeout(timeout)) {
        bytes.add(chunk);
        if (total != null && total > 0) onProgress?.call(bytes.length / total);
      }
      return bytes.takeBytes();
    } on TimeoutException {
      throw const ImageSourceException('The download took too long. Check the connection and try again.');
    } on http.ClientException {
      throw const ImageSourceException('No connection to that address. Check the internet and the address.');
    }
  }

  void close() => _client.close();
}
