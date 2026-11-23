import 'package:flutter/material.dart';

import 'screens/smoke_test_page.dart';
import 'services/classifier.dart';

void main() => runApp(const TmClassifierApp());

/// Owns the one [Classifier] for the whole app: it is loaded here at start-up,
/// handed to the screens that need it by constructor injection, and closed when
/// the app shuts down. No screen calls [Classifier.load] itself.
class TmClassifierApp extends StatefulWidget {
  const TmClassifierApp({super.key});

  @override
  State<TmClassifierApp> createState() => _TmClassifierAppState();
}

class _TmClassifierAppState extends State<TmClassifierApp> {
  late final Future<Classifier> _bootstrap;

  /// Kept so [dispose] can release the native interpreter.
  Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _bootstrap = Classifier.load().then((c) => _classifier = c);
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TM Classifier',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3F6EFF),
        useMaterial3: true,
      ),
      home: FutureBuilder<Classifier>(
        future: _bootstrap,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const _LoadingScreen();
            case ConnectionState.done:
              final error = snapshot.error;
              if (error != null) return _StartupErrorScreen(error: error);
              return SmokeTestPage(classifier: snapshot.data!);
          }
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading the model…'),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of a red error screen when the model or the labels are
/// missing: it names what could not be found and where it was expected.
class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final message = error is ClassifierException
        ? (error as ClassifierException).message
        : 'The model could not be loaded.';
    final detail = error is ClassifierException
        ? (error as ClassifierException).detail
        : error.toString();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (detail != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
