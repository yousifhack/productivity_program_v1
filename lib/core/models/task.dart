import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { assigned, acknowledged, inProgress, blocked, done }

class Task {
  Task({
    required this.id,
    required this.teamId,
    required this.title,
    required this.priority,
    required this.status,
    required this.assignedToUid,
    required this.assignedByUid,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueAt,
    this.assignedAt,
    this.ackDeadlineAt,
    this.acknowledgedAt,
    this.blockedReason,
    this.lastUpdateAt,
    this.lastUpdatedByUid,
    this.escalationLevel,
  });

  final String id;
  final String teamId;
  final String title;
  final int priority;
  final TaskStatus status;
  final String assignedToUid;
  final String assignedByUid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final DateTime? dueAt;
  final DateTime? assignedAt;
  final DateTime? ackDeadlineAt;
  final DateTime? acknowledgedAt;
  final String? blockedReason;
  final DateTime? lastUpdateAt;
  final String? lastUpdatedByUid;
  final int? escalationLevel;

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      teamId: data['teamId'] as String? ?? 'demo-team',
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String?,
      priority: (data['priority'] as num?)?.toInt() ?? 2,
      status: _statusFromString(data['status'] as String?),
      assignedToUid: data['assignedToUid'] as String? ?? '',
      assignedByUid: data['assignedByUid'] as String? ?? '',
      createdAt: _fromTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _fromTimestamp(data['updatedAt']) ?? DateTime.now(),
      dueAt: _fromTimestamp(data['dueAt']),
      assignedAt: _fromTimestamp(data['assignedAt']),
      ackDeadlineAt: _fromTimestamp(data['ackDeadlineAt']),
      acknowledgedAt: _fromTimestamp(data['acknowledgedAt']),
      blockedReason: data['blockedReason'] as String?,
      lastUpdateAt: _fromTimestamp(data['lastUpdateAt']),
      lastUpdatedByUid: data['lastUpdatedByUid'] as String?,
      escalationLevel: (data['escalationLevel'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': _statusToString(status),
      'assignedToUid': assignedToUid,
      'assignedByUid': assignedByUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueAt': dueAt != null ? Timestamp.fromDate(dueAt!) : null,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'ackDeadlineAt': ackDeadlineAt != null
          ? Timestamp.fromDate(ackDeadlineAt!)
          : null,
      'acknowledgedAt': acknowledgedAt != null
          ? Timestamp.fromDate(acknowledgedAt!)
          : null,
      'blockedReason': blockedReason,
      'lastUpdateAt': lastUpdateAt != null
          ? Timestamp.fromDate(lastUpdateAt!)
          : null,
      'lastUpdatedByUid': lastUpdatedByUid,
      'escalationLevel': escalationLevel,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    int? priority,
    TaskStatus? status,
    String? assignedToUid,
    String? assignedByUid,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    DateTime? assignedAt,
    DateTime? ackDeadlineAt,
    DateTime? acknowledgedAt,
    String? blockedReason,
    DateTime? lastUpdateAt,
    String? lastUpdatedByUid,
    int? escalationLevel,
  }) {
    return Task(
      id: id,
      teamId: teamId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedToUid: assignedToUid ?? this.assignedToUid,
      assignedByUid: assignedByUid ?? this.assignedByUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      assignedAt: assignedAt ?? this.assignedAt,
      ackDeadlineAt: ackDeadlineAt ?? this.ackDeadlineAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      blockedReason: blockedReason ?? this.blockedReason,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      lastUpdatedByUid: lastUpdatedByUid ?? this.lastUpdatedByUid,
      escalationLevel: escalationLevel ?? this.escalationLevel,
    );
  }
}

TaskStatus _statusFromString(String? value) {
  switch (value) {
    case 'assigned':
      return TaskStatus.assigned;
    case 'acknowledged':
      return TaskStatus.acknowledged;
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'blocked':
      return TaskStatus.blocked;
    case 'done':
      return TaskStatus.done;
    default:
      return TaskStatus.assigned;
  }
}

String _statusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.assigned:
      return 'assigned';
    case TaskStatus.acknowledged:
      return 'acknowledged';
    case TaskStatus.inProgress:
      return 'in_progress';
    case TaskStatus.blocked:
      return 'blocked';
    case TaskStatus.done:
      return 'done';
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
