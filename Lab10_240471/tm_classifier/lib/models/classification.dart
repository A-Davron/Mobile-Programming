import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/classifier.dart';

/// Where the picture came from. Every source ends in the same [Classification].
enum ImageOrigin {
  camera('Camera', Icons.photo_camera_outlined),
  gallery('Gallery', Icons.photo_library_outlined),
  download('Download', Icons.cloud_download_outlined),
  sample('Sample image', Icons.science_outlined);

  const ImageOrigin(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// One finished classification: the picture, every label with its confidence,
/// and where the picture came from. History keeps these, so reopening a result
/// never runs the model again.
class Classification {
  Classification({
    required this.bytes,
    required this.predictions,
    required this.origin,
    this.inference,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final Uint8List bytes;

  /// Sorted, highest confidence first.
  final List<Prediction> predictions;
  final ImageOrigin origin;
  final Duration? inference;
  final DateTime createdAt;

  Prediction get top => predictions.first;
}
