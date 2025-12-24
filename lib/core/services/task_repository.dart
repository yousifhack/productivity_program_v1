import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../utils/constants.dart';
import 'firestore_paths.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks(String teamId);
  Stream<Task?> watchTask(String taskId);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
}

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection(FirestorePaths.tasks);

  @override
  Stream<List<Task>> watchTasks(String teamId) {
    return _tasks
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Task.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<Task?> watchTask(String taskId) {
    return _tasks.doc(taskId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Task.fromFirestore(doc.id, doc.data()!);
    });
  }

  @override
  Future<void> createTask(Task task) {
    return _tasks.doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> updateTask(Task task) {
    return _tasks.doc(task.id).update(task.toFirestore());
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirestoreTaskRepository(FirebaseFirestore.instance);
});

Task buildNewTask({
  required String title,
  required String assignedToUid,
  required String assignedByUid,
  String teamId = AppConstants.demoTeamId,
  String? description,
  int priority = 2,
  Duration sla = AppConstants.ackDefault,
  DateTime? dueAt,
}) {
  final now = DateTime.now();
  final taskId = _uuid();
  return Task(
    id: taskId,
    teamId: teamId,
    title: title,
    description: description,
    priority: priority,
    status: TaskStatus.assigned,
    assignedToUid: assignedToUid,
    assignedByUid: assignedByUid,
    createdAt: now,
    updatedAt: now,
    dueAt: dueAt,
    assignedAt: now,
    ackDeadlineAt: now.add(sla),
    lastUpdateAt: now,
    lastUpdatedByUid: assignedByUid,
  );
}

String _uuid() {
  return FirebaseFirestore.instance.collection('_').doc().id;
}
