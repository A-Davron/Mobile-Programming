import 'package:flutter/material.dart';

import '../models/classification.dart';
import '../services/session_history.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'result_screen.dart';

/// Screen 4. Every classification of this session, newest first. Tapping one
/// reopens its Result screen from the stored predictions; the model does not
/// run again.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history});

  final SessionHistory history;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          final items = history.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpace.page.copyWith(bottom: 0),
                child: Text('History', style: text.headlineSmall),
              ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'Nothing classified yet',
                        message: 'Take a photo, pick one from the gallery or download one. '
                            'Every result of this session lands here.',
                      )
                    : ListView.separated(
                        padding: AppSpace.page,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
                        itemBuilder: (context, i) => _HistoryTile(entry: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final Classification entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(entry.createdAt).format(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpace.sm + AppSpace.xs),
        leading: ClipRRect(
          borderRadius: AppRadius.smAll,
          child: Image.memory(entry.bytes, width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(entry.top.label),
        subtitle: Row(
          children: [
            Icon(entry.origin.icon, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpace.xs),
            Flexible(child: Text('${entry.origin.label} · $time', overflow: TextOverflow.ellipsis)),
          ],
        ),
        trailing: Text(
          entry.top.percent,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.primary),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(classification: entry)),
        ),
      ),
    );
  }
}
