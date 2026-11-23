import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// Screen 1. Doubles as the loading screen: while [classifier] is null and
/// there is no [error], the model is still loading and Get started waits.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.classifier,
    required this.error,
    required this.onGetStarted,
  });

  final Classifier? classifier;
  final Object? error;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final labels = classifier?.labels;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: AppSpace.page,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppSpace.page.vertical,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpace.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpace.md),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: AppRadius.lgAll,
                      ),
                      child: Icon(Icons.center_focus_strong, size: 36, color: scheme.onPrimary),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text('TM Classifier', style: text.displaySmall),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      labels == null
                          ? 'Recognises the objects on our desk, right on your phone.'
                          : 'Recognises ${labels.length} objects from our desk, '
                              'right on your phone — no internet needed.',
                      style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    if (error != null)
                      _StartupError(error: error!)
                    else if (labels == null)
                      const _Loading()
                    else ...[
                      Text('IT KNOWS', style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.sm,
                        children: [for (final l in labels) Chip(label: Text(l))],
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: AppSpace.lg),
                    if (error == null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: classifier == null ? null : onGetStarted,
                          child: Text(classifier == null ? 'Loading the model…' : 'Get started'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(borderRadius: AppRadius.smAll, child: const LinearProgressIndicator()),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Loading the model and its labels…',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Shown instead of a red error screen when the model or labels are missing:
/// it names what could not be found and where it was expected.
class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final e = error;
    final message = e is ClassifierException ? e.message : 'The model could not be loaded.';
    final detail = e is ClassifierException ? e.detail : e.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: AppRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: scheme.error),
              const SizedBox(width: AppSpace.sm),
              Expanded(child: Text(message, style: text.titleMedium?.copyWith(color: scheme.error))),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(detail, style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}
