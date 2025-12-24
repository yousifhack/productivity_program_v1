import 'package:cloud_firestore/cloud_firestore.dart';

enum EventActionType {
  taskAssigned,
  taskAcked,
  taskBlocked,
  taskDone,
  commentAdded,
  escalated,
}

class AuditEvent {
  AuditEvent({
    required this.id,
    required this.teamId,
    required this.actorUid,
    required this.actionType,
    required this.createdAt,
    this.taskId,
    this.targetUid,
    this.metadata = const {},
  });

  final String id;
  final String teamId;
  final String actorUid;
  final EventActionType actionType;
  final DateTime createdAt;
  final String? taskId;
  final String? targetUid;
  final Map<String, dynamic> metadata;

  factory AuditEvent.fromFirestore(String id, Map<String, dynamic> data) {
    return AuditEvent(
      id: id,
      teamId: data['teamId'] as String? ?? 'demo-team',
      actorUid: data['actorUid'] as String? ?? '',
      actionType: _actionFromString(data['actionType'] as String?),
      createdAt: _fromTimestamp(data['createdAt']) ?? DateTime.now(),
      taskId: data['taskId'] as String?,
      targetUid: data['targetUid'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'actorUid': actorUid,
      'actionType': _actionToString(actionType),
      'createdAt': Timestamp.fromDate(createdAt),
      'taskId': taskId,
      'targetUid': targetUid,
      'metadata': metadata,
    };
  }
}

EventActionType _actionFromString(String? value) {
  switch (value) {
    case 'TASK_ASSIGNED':
      return EventActionType.taskAssigned;
    case 'TASK_ACKED':
      return EventActionType.taskAcked;
    case 'TASK_BLOCKED':
      return EventActionType.taskBlocked;
    case 'TASK_DONE':
      return EventActionType.taskDone;
    case 'COMMENT_ADDED':
      return EventActionType.commentAdded;
    case 'ESCALATED':
      return EventActionType.escalated;
    default:
      return EventActionType.taskAssigned;
  }
}

String _actionToString(EventActionType action) {
  switch (action) {
    case EventActionType.taskAssigned:
      return 'TASK_ASSIGNED';
    case EventActionType.taskAcked:
      return 'TASK_ACKED';
    case EventActionType.taskBlocked:
      return 'TASK_BLOCKED';
    case EventActionType.taskDone:
      return 'TASK_DONE';
    case EventActionType.commentAdded:
      return 'COMMENT_ADDED';
    case EventActionType.escalated:
      return 'ESCALATED';
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
