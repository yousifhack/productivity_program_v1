import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_repository.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(FirebaseFirestore.instance);
});

class ContactsRepository {
  ContactsRepository(this._db);
  final FirebaseFirestore _db;

  Stream<QuerySnapshot<Map<String, dynamic>>> contactsStream(String myUid) {
    return _db
        .collection('users')
        .doc(myUid)
        .collection('contacts')
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Future<void> addByInviteCode({
    required String myUid,
    required String inviteCode,
  }) async {
    final code = inviteCode.trim();
    if (code.isEmpty) throw StateError('Enter an ID.');

    // Find target user by inviteCode
    final q = await _db.collection('users').where('inviteCode', isEqualTo: code).limit(1).get();
    if (q.docs.isEmpty) throw StateError('No user found with this ID.');
    final otherDoc = q.docs.first;
    final otherUid = otherDoc.id;

    if (otherUid == myUid) throw StateError('You cannot add yourself.');

    final myDoc = await _db.collection('users').doc(myUid).get();
    if (!myDoc.exists) throw StateError('Your user record is missing in Firestore.');

    final myName = (myDoc.data()?['displayName'] ?? '').toString();
    final otherName = (otherDoc.data()['displayName'] ?? '').toString();

    final myContactRef = _db.collection('users').doc(myUid).collection('contacts').doc(otherUid);
    final otherContactRef = _db.collection('users').doc(otherUid).collection('contacts').doc(myUid);

    final convId = ChatRepository.chatIdFor(myUid, otherUid);
    final convRef = _db.collection('conversations').doc(convId);

    final now = FieldValue.serverTimestamp();

    await _db.runTransaction((tx) async {
      // Ensure conversation exists
      final convSnap = await tx.get(convRef);
      if (!convSnap.exists) {
        tx.set(convRef, {
          'members': [myUid, otherUid],
          'createdAt': now,
          'lastMessageText': '',
          'lastMessageAt': now,
          'lastMessageSenderId': null,
          'unreadCount': {myUid: 0, otherUid: 0},
        });
      }

      tx.set(
        myContactRef,
        {
          'otherUid': otherUid,
          'displayName': otherName.isNotEmpty ? otherName : 'Colleague',
          'addedAt': now,
          'hasUnread': false,
          'unreadCount': 0,
          'lastMessageAt': now,
          'lastMessageText': '',
          'conversationId': convId,
        },
        SetOptions(merge: true),
      );

      tx.set(
        otherContactRef,
        {
          'otherUid': myUid,
          'displayName': myName.isNotEmpty ? myName : 'Colleague',
          'addedAt': now,
          'hasUnread': false,
          'unreadCount': 0,
          'lastMessageAt': now,
          'lastMessageText': '',
          'conversationId': convId,
        },
        SetOptions(merge: true),
      );
    });
  }
}
