import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/classifier.dart';
import 'services/session_history.dart';
import 'theme/app_theme.dart';

void main() => runApp(const TmClassifierApp());

/// Owns the one [Classifier] and the session history for the whole app. The
/// classifier is loaded here at start-up, handed to the screens that need it
/// by constructor injection, and closed when the app shuts down. No screen
/// calls [Classifier.load] itself.
class TmClassifierApp extends StatefulWidget {
  const TmClassifierApp({super.key});

  @override
  State<TmClassifierApp> createState() => _TmClassifierAppState();
}

class _TmClassifierAppState extends State<TmClassifierApp> {
  final _history = SessionHistory();
  Classifier? _classifier;
  Object? _error;

  @override
  void initState() {
    super.initState();
    Classifier.load().then(
      (c) {
        if (mounted) {
          setState(() => _classifier = c);
        } else {
          c.close();
        }
      },
      onError: (Object e) {
        if (mounted) setState(() => _error = e);
      },
    );
  }

  @override
  void dispose() {
    _classifier?.close();
    _history.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TM Classifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => WelcomeScreen(
          classifier: _classifier,
          error: _error,
          onGetStarted: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => HomeShell(classifier: _classifier!, history: _history),
            ),
          ),
        ),
      ),
    );
  }
}
