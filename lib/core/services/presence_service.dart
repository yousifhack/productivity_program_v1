import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  PresenceService(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _beat();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _beat());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _beat() async {
    final u = _auth.currentUser;
    if (u == null) return;

    await _db.collection('users').doc(u.uid).set({
      'lastSeenAt': FieldValue.serverTimestamp(),
      'status': 'active',
    }, SetOptions(merge: true));
  }
}
