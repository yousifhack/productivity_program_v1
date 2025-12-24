import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity_program_v1/core/services/auth_repository.dart';

class ManagerDashboardPage extends ConsumerWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Baseline OK.\nNext: Live Dashboard + Buckets + Quick Assign.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

