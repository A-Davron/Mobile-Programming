import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/classification.dart';
import '../services/classifier.dart';
import '../services/image_sources.dart';
import '../services/session_history.dart';
import '../theme/app_theme.dart';
import '../widgets/download_dialog.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'model_screen.dart';
import 'result_screen.dart';

/// The bottom navigation bar (Home, History, Model) and the one
/// classification path every image source goes through:
/// bytes → classify → History → Result screen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.classifier, required this.history});

  final Classifier classifier;
  final SessionHistory history;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _sampleAsset = 'assets/model/sample.jpg';

  final _sources = ImageSources();
  int _tab = 0;
  bool _busy = false;

  @override
  void dispose() {
    _sources.close();
    super.dispose();
  }

  /// The single classification path. [loadBytes] returning null means the
  /// user cancelled: nothing happens and no error is shown.
  Future<void> _classify(ImageOrigin origin, Future<Uint8List?> Function() loadBytes) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await loadBytes();
      if (bytes == null || !mounted) return;

      setState(() => _busy = true);
      // Let the progress overlay paint before the model blocks the UI thread.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final predictions = widget.classifier.classify(bytes);
      final entry = Classification(
        bytes: bytes,
        predictions: predictions,
        origin: origin,
        inference: widget.classifier.lastInference,
      );
      widget.history.add(entry);

      if (!mounted) return;
      setState(() => _busy = false);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ResultScreen(classification: entry)),
      );
    } on ImageSourceException catch (e) {
      _showError(messenger, e.message);
    } on ClassifierException catch (e) {
      _showError(messenger, e.message);
    } catch (e) {
      _showError(messenger, 'Something went wrong while classifying that picture.');
    }
  }

  void _showError(ScaffoldMessengerState messenger, String message) {
    if (mounted) setState(() => _busy = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Extra source for quick checks: the bundled sample image.
  Future<Uint8List?> _sampleBytes() async {
    try {
      final data = await rootBundle.load(_sampleAsset);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      throw const ClassifierException(
        'The sample image is missing. Put a photo at $_sampleAsset and rebuild.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        history: widget.history,
        onCamera: () => _classify(ImageOrigin.camera, _sources.fromCamera),
        onGallery: () => _classify(ImageOrigin.gallery, _sources.fromGallery),
        onDownload: () => _classify(ImageOrigin.download, () => showDownloadDialog(context, _sources)),
        onSample: () => _classify(ImageOrigin.sample, _sampleBytes),
      ),
      HistoryScreen(history: widget.history),
      ModelScreen(classifier: widget.classifier),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _tab, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.history), label: 'History'),
              NavigationDestination(icon: Icon(Icons.memory_outlined), selectedIcon: Icon(Icons.memory), label: 'Model'),
            ],
          ),
        ),
        if (_busy) const _BusyOverlay(),
      ],
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: ColoredBox(
        color: scheme.scrim.withValues(alpha: 0.35),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpace.md),
                  Text('Classifying…', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
