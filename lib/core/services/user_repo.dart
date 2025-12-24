import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

final userRepoProvider = Provider<UserRepo>((ref) {
  return UserRepo(FirebaseFirestore.instance);
});

class UserRepo {
  UserRepo(this._db);
  final FirebaseFirestore _db;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }
}
