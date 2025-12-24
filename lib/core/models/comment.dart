import 'package:cloud_firestore/cloud_firestore.dart';

enum CommentKind { update, question }

class TaskComment {
  TaskComment({
    required this.id,
    required this.taskId,
    required this.authorUid,
    required this.body,
    required this.createdAt,
    this.kind = CommentKind.update,
  });

  final String id;
  final String taskId;
  final String authorUid;
  final String body;
  final DateTime createdAt;
  final CommentKind kind;

  factory TaskComment.fromFirestore(
    String id,
    String taskId,
    Map<String, dynamic> data,
  ) {
    return TaskComment(
      id: id,
      taskId: taskId,
      authorUid: data['authorUid'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _fromTimestamp(data['createdAt']) ?? DateTime.now(),
      kind: _kindFromString(data['kind'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'kind': kind.name,
    };
  }
}

CommentKind _kindFromString(String? value) {
  switch (value) {
    case 'question':
      return CommentKind.question;
    case 'update':
    default:
      return CommentKind.update;
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
