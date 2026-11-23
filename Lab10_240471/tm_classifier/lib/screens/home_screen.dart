import 'package:flutter/material.dart';

import '../models/classification.dart';
import '../services/session_history.dart';
import '../theme/app_theme.dart';
import '../widgets/action_card.dart';
import 'result_screen.dart';

/// Screen 2. The three sources and the most recent result.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.history,
    required this.onCamera,
    required this.onGallery,
    required this.onDownload,
    required this.onSample,
  });

  final SessionHistory history;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDownload;
  final VoidCallback onSample;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: AppSpace.page,
        children: [
          const SizedBox(height: AppSpace.sm),
          Text('What are we looking at?', style: text.headlineSmall),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Pick a picture. It is classified on the phone, offline.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpace.lg),
          ActionCard(
            icon: Icons.photo_camera_outlined,
            title: 'Take a photo',
            subtitle: 'Use the phone camera',
            onTap: onCamera,
          ),
          const SizedBox(height: AppSpace.md - AppSpace.xs),
          ActionCard(
            icon: Icons.photo_library_outlined,
            title: 'Choose from gallery',
            subtitle: 'A photo or screenshot on this phone',
            onTap: onGallery,
          ),
          const SizedBox(height: AppSpace.md - AppSpace.xs),
          ActionCard(
            icon: Icons.cloud_download_outlined,
            title: 'Download an image',
            subtitle: 'Paste the address of a picture',
            onTap: onDownload,
          ),
          const SizedBox(height: AppSpace.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onSample,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Try the sample image'),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text('MOST RECENT', style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: AppSpace.sm),
          ListenableBuilder(
            listenable: history,
            builder: (context, _) {
              final latest = history.latest;
              return latest == null ? const _NoResultYet() : _LatestResult(entry: latest);
            },
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

class _NoResultYet extends StatelessWidget {
  const _NoResultYet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          children: [
            Icon(Icons.image_search, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                'No result yet. Your latest classification will show up here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestResult extends StatelessWidget {
  const _LatestResult({required this.entry});

  final Classification entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpace.sm + AppSpace.xs),
        leading: ClipRRect(
          borderRadius: AppRadius.smAll,
          child: Image.memory(entry.bytes, width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(entry.top.label),
        subtitle: Text('${entry.top.percent} · ${entry.origin.label}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(classification: entry)),
        ),
      ),
    );
  }
}
