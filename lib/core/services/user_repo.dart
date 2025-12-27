import 'dart:math';

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

  /// Creates users/{uid} doc if missing.
  /// IMPORTANT: keep fields compatible with your existing Firestore model.
  Future<void> createUserDocIfMissing({
    required String uid,
    required String displayName,
    required String email,
    required String role,
    required String teamId,
  }) async {
    final ref = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        // Ensure inviteCode exists even for older accounts
        final data = snap.data()!;
        final existing = (data['inviteCode'] as String?)?.trim();
        if (existing == null || existing.isEmpty) {
          tx.update(ref, {'inviteCode': _generateInviteCode(12)});
        }
        // Also ensure displayName exists (optional)
        if ((data['displayName'] as String?)?.trim().isEmpty ?? true) {
          tx.update(ref, {'displayName': displayName});
        }
        return;
      }

      tx.set(ref, {
        'role': role,
        'displayName': displayName,
        'teamId': teamId,
        'status': 'active',
        'lastSeenAt': FieldValue.serverTimestamp(),
        'deviceLabel': null,
        'email': email,
        'inviteCode': _generateInviteCode(12),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Ensure this user has an inviteCode (10–15 chars) stored in users/{uid}.
  Future<String> ensureInviteCode(String uid) async {
    final ref = _db.collection('users').doc(uid);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('users/$uid does not exist.');
      }
      final data = snap.data()!;
      final existing = (data['inviteCode'] as String?)?.trim();
      if (existing != null && existing.isNotEmpty) return existing;

      final code = _generateInviteCode(12);
      tx.update(ref, {'inviteCode': code});
      return code;
    });
  }

  /// Find a user by inviteCode (the ID the user shares).
  Future<DocumentSnapshot<Map<String, dynamic>>?> findUserByInviteCode(String code) async {
    final q = await _db.collection('users').where('inviteCode', isEqualTo: code.trim()).limit(1).get();
    if (q.docs.isEmpty) return null;
    return q.docs.first;
  }

  /// Add a contact by invite code. Creates users/{me}/contacts/{other}.
  Future<void> addContactByInviteCode({
    required String myUid,
    required String inviteCode,
  }) async {
    final target = await findUserByInviteCode(inviteCode);
    if (target == null) {
      throw StateError('No user found with this ID.');
    }

    final otherUid = target.id;
    if (otherUid == myUid) {
      throw StateError('You cannot add yourself.');
    }

    final myContactRef = _db.collection('users').doc(myUid).collection('contacts').doc(otherUid);
    final otherContactRef = _db.collection('users').doc(otherUid).collection('contacts').doc(myUid);

    final now = FieldValue.serverTimestamp();

    final batch = _db.batch();
    batch.set(myContactRef, {'addedAt': now, 'hasUnread': false}, SetOptions(merge: true));
    batch.set(otherContactRef, {'addedAt': now, 'hasUnread': false}, SetOptions(merge: true)); // mutual add
    await batch.commit();
  }

  /// Watch contact uids under users/{uid}/contacts
  Stream<List<String>> watchContactUids(String uid) {
    return _db.collection('users').doc(uid).collection('contacts').snapshots().map(
          (s) => s.docs.map((d) => d.id).toList(),
        );
  }

  static String _generateInviteCode(int len) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusing 0/O/1/I
    final r = Random.secure();
    final out = StringBuffer();
    for (int i = 0; i < len; i++) {
      out.write(chars[r.nextInt(chars.length)]);
    }
    return out.toString();
  }
}
