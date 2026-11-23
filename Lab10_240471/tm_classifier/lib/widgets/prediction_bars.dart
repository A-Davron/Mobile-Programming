import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// One row per label: name, a bar, the percentage. The list arrives sorted, so
/// the first row is the top result and is drawn emphasised.
class PredictionBars extends StatelessWidget {
  const PredictionBars({super.key, required this.predictions});

  final List<Prediction> predictions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < predictions.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: _PredictionRow(prediction: predictions[i], isTop: i == 0),
          ),
      ],
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({required this.prediction, required this.isTop});

  final Prediction prediction;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = isTop
        ? text.titleMedium?.copyWith(color: scheme.primary)
        : text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(prediction.label, style: style, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: prediction.confidence.clamp(0, 1).toDouble(),
              minHeight: isTop ? 10 : 6,
              color: isTop ? scheme.primary : scheme.outline,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        SizedBox(
          width: 64,
          child: Text(prediction.percent, style: style, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
