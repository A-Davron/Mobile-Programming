import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/image_sources.dart';
import '../theme/app_theme.dart';

/// Asks for an image address, downloads it with a progress bar and returns the
/// bytes. Returns null when the user cancels. Errors stay inside the dialog so
/// the user can fix the address and try again.
Future<Uint8List?> showDownloadDialog(BuildContext context, ImageSources sources) {
  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DownloadDialog(sources: sources),
  );
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog({required this.sources});

  final ImageSources sources;

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  final _controller = TextEditingController();
  bool _downloading = false;
  double? _progress;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = null;
      _error = null;
    });
    try {
      final bytes = await widget.sources.fromUrl(
        _controller.text,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) Navigator.of(context).pop(bytes);
    } on ImageSourceException catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Download an image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            enabled: !_downloading,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _download(),
            decoration: const InputDecoration(
              labelText: 'Image address',
              hintText: 'https://example.com/photo.jpg',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          if (_downloading) ...[
            ClipRRect(
              borderRadius: AppRadius.smAll,
              child: LinearProgressIndicator(value: _progress),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              _progress == null ? 'Downloading…' : 'Downloading… ${(_progress! * 100).round()}%',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ] else if (_error != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 18, color: scheme.error),
                const SizedBox(width: AppSpace.sm),
                Expanded(child: Text(_error!, style: text.bodySmall?.copyWith(color: scheme.error))),
              ],
            )
          else
            Text(
              'Long-press a picture in the browser and choose "Copy image address".',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _downloading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _downloading ? null : _download,
          child: const Text('Download'),
        ),
      ],
    );
  }
}
