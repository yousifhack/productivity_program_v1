import 'package:intl/intl.dart';

import '../models/task.dart';

class TimeUtils {
  static final DateFormat hourMinute = DateFormat.Hm();

  static String relativeFromNow(DateTime? time) {
    if (time == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds.abs() < 60) return '${diff.inSeconds.abs()}s';
    if (diff.inMinutes.abs() < 90) return '${diff.inMinutes.abs()}m';
    if (diff.inHours.abs() < 48) return '${diff.inHours.abs()}h';
    return '${diff.inDays.abs()}d';
  }

  static bool isOverdue(Task task, {DateTime? now}) {
    if (task.dueAt == null) return false;
    final current = now ?? DateTime.now();
    return task.status != TaskStatus.done && current.isAfter(task.dueAt!);
  }

  static bool isWaitingAck(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return task.status == TaskStatus.assigned &&
        (task.assignedAt?.isBefore(current) ?? false) &&
        task.acknowledgedAt == null;
  }

  static bool isSlaBreached(Task task, {DateTime? now}) {
    if (task.ackDeadlineAt == null || task.acknowledgedAt != null) return false;
    final current = now ?? DateTime.now();
    return current.isAfter(task.ackDeadlineAt!);
  }

  static bool isSilent(Task task, Duration threshold, {DateTime? now}) {
    final reference = task.lastUpdateAt ?? task.assignedAt;
    if (reference == null) return false;
    final current = now ?? DateTime.now();
    if (!{
      TaskStatus.acknowledged,
      TaskStatus.inProgress,
      TaskStatus.blocked,
    }.contains(task.status)) {
      return false;
    }
    return current.difference(reference) > threshold;
  }
}
