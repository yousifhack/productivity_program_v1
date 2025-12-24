import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import 'firestore_paths.dart';

abstract class CommentRepository {
  Stream<List<TaskComment>> watchComments(String taskId);
  Future<void> addComment(TaskComment comment);
}

class FirestoreCommentRepository implements CommentRepository {
  FirestoreCommentRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Stream<List<TaskComment>> watchComments(String taskId) {
    return _firestore
        .collection(FirestorePaths.taskComments(taskId))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TaskComment.fromFirestore(doc.id, taskId, doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<void> addComment(TaskComment comment) {
    return _firestore
        .collection(FirestorePaths.taskComments(comment.taskId))
        .doc(comment.id)
        .set(comment.toFirestore());
  }
}

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return FirestoreCommentRepository(FirebaseFirestore.instance);
});
