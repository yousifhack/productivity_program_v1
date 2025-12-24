import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/time_utils.dart';
import 'status_pill.dart';
import 'timer_chip.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = TimeUtils.isOverdue(task);
    final slaBreached = TimeUtils.isSlaBreached(task);

    final priorityColor = switch (task.priority) {
      1 => Colors.redAccent,
      2 => Colors.orangeAccent,
      _ => Colors.lightGreenAccent,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(
                    label:
                        task.status.name.replaceAll('_', ' ').toUpperCase(),
                    color: overdue ? Colors.redAccent : Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            priorityColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'P${task.priority}',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Updated ${TimeUtils.relativeFromNow(task.updatedAt)} ago',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (task.dueAt != null)
                    TimerChip(
                      label: 'Due',
                      target: task.dueAt!,
                      negativeColor: overdue
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                    ),
                  const SizedBox(width: 10),
                  if (task.ackDeadlineAt != null &&
                      task.acknowledgedAt == null)
                    TimerChip(
                      label: 'SLA',
                      target: task.ackDeadlineAt!,
                      negativeColor: slaBreached
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                      positiveColor: Colors.lightGreenAccent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
