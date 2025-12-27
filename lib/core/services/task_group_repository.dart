import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_group.dart';

final taskGroupRepositoryProvider = Provider<TaskGroupRepository>((ref) {
  return TaskGroupRepository(FirebaseFirestore.instance);
});

class TaskGroupRepository {
  TaskGroupRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _groups(String uid) =>
      _db.collection('users').doc(uid).collection('taskGroups');

  Stream<List<TaskGroup>> watchGroups(String uid) {
    return _groups(uid)
        .orderBy('createdAtMillis', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskGroup.fromMap(d.id, d.data())).toList());
  }

  Future<void> createGroup({
    required String uid,
    required String name,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _groups(uid).add(TaskGroup(
      id: '',
      name: name,
      ownerUid: uid,
      createdAtMillis: now,
    ).toMap());
  }

  Future<void> deleteGroup({
    required String uid,
    required String groupId,
  }) async {
    // Phase 1: only deletes group doc (tasks inside handling comes later).
    await _groups(uid).doc(groupId).delete();
  }
}
