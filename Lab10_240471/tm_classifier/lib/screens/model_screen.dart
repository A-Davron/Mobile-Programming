import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';
import 'smoke_test_page.dart';

/// Screen 5. What the model knows, read from the loaded classifier, plus the
/// design credit. The labels come from [Classifier.labels] — the same list the
/// model's outputs are paired with — not from a second read of labels.txt.
class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.classifier});

  final Classifier classifier;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final labels = classifier.labels;
    const size = Classifier.inputSize;

    return SafeArea(
      child: ListView(
        padding: AppSpace.page,
        children: [
          Text('Model', style: text.headlineSmall),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Trained in Teachable Machine, running on the phone with TensorFlow Lite.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(child: _Stat(value: '${labels.length}', label: 'Classes')),
              const SizedBox(width: AppSpace.md - AppSpace.xs),
              const Expanded(child: _Stat(value: '$size×$size', label: 'Input size')),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          _Section(
            title: 'LABELS',
            child: Column(
              children: [
                for (var i = 0; i < labels.length; i++)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: scheme.primaryContainer,
                      child: Text('$i', style: text.labelMedium?.copyWith(color: scheme.onPrimaryContainer)),
                    ),
                    title: Text(labels[i], style: text.bodyLarge),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          _Section(
            title: 'FILES',
            child: Column(
              children: [
                _InfoRow(name: 'Model', value: Classifier.modelAsset.split('/').last),
                _InfoRow(name: 'Labels', value: Classifier.labelsAsset.split('/').last),
                const _InfoRow(name: 'Input tensor', value: '[1, $size, $size, 3] float32'),
                _InfoRow(name: 'Output tensor', value: '[1, ${labels.length}] float32'),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          _Section(
            title: 'DESIGN',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DesignCredit.name, style: text.titleMedium),
                const SizedBox(height: AppSpace.xs),
                Text('by ${DesignCredit.author} · ${DesignCredit.licence}', style: text.bodySmall),
                const SizedBox(height: AppSpace.xs),
                SelectableText(DesignCredit.url, style: text.bodySmall?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => SmokeTestPage(classifier: classifier)),
            ),
            icon: const Icon(Icons.bug_report_outlined),
            label: const Text('Run the smoke test'),
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: text.headlineSmall?.copyWith(color: scheme.primary)),
            Text(label, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: AppSpace.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(name, style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: AppSpace.md),
          Flexible(child: Text(value, style: text.titleSmall, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
