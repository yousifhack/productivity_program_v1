import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import 'firestore_paths.dart';

abstract class EventRepository {
  Future<void> logEvent(AuditEvent event);
  Stream<List<AuditEvent>> watchEvents(String teamId, {int limit});
}

class FirestoreEventRepository implements EventRepository {
  FirestoreEventRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection(FirestorePaths.events);

  @override
  Future<void> logEvent(AuditEvent event) {
    return _events.doc(event.id).set(event.toFirestore());
  }

  @override
  Stream<List<AuditEvent>> watchEvents(String teamId, {int limit = 100}) {
    return _events
        .where('teamId', isEqualTo: teamId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditEvent.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return FirestoreEventRepository(FirebaseFirestore.instance);
});
