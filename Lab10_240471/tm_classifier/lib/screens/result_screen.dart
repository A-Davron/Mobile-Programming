import 'package:flutter/material.dart';

import '../models/classification.dart';
import '../theme/app_theme.dart';
import '../widgets/prediction_bars.dart';

/// Screen 3. The same widget for every source: the picture centred and
/// uncropped, then every label with a bar and its percentage.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.classification});

  final Classification classification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxImageHeight = MediaQuery.sizeOf(context).height * 0.5;
    final ms = classification.inference?.inMilliseconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: Chip(
              avatar: Icon(classification.origin.icon, size: 18, color: scheme.onSecondaryContainer),
              label: Text(classification.origin.label),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpace.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxImageHeight),
                  child: ClipRRect(
                    borderRadius: AppRadius.lgAll,
                    child: Image.memory(classification.bytes, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text('IT LOOKS LIKE', style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: AppSpace.xs),
              Text(classification.top.label, style: text.headlineSmall),
              const SizedBox(height: AppSpace.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
                  child: PredictionBars(predictions: classification.predictions),
                ),
              ),
              if (ms != null) ...[
                const SizedBox(height: AppSpace.sm),
                Text(
                  'Classified on the phone in $ms ms',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
