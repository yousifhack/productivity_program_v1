import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity_program_v1/core/services/user_repo.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(userRepoProvider).ensureInviteCode(uid),
      builder: (context, snap) {
        final inviteCode = snap.data ?? '';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              const Text('Your User ID (share this):'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteCode.isEmpty ? 'Loading…' : inviteCode,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: inviteCode.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: inviteCode));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Tools (coming soon)'),
              ),
            ],
          ),
        );
      },
    );
  }
}

