import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';

class AiActionsSheet extends ConsumerWidget {
  const AiActionsSheet({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(aiServiceProvider).fetchNextBestActions(teamId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final actions = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Next Best Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...actions.map(
                (action) => ListTile(
                  leading: const Icon(Icons.bolt),
                  title: Text(action.actionType),
                  subtitle: Text(action.rationale),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
