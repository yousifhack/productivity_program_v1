import 'package:flutter/material.dart';

import '../../../core/utils/constants.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task $taskId')),
      body: Padding(
        padding: AppConstants.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Detail',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Status, SLA timers, comments, and actions will appear here.',
            ),
          ],
        ),
      ),
    );
  }
}
