import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

class ChatRepository {
  ChatRepository(this._db, this._storage);
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  static String chatIdFor(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream({
    required String chatId,
  }) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendText({
    required String myUid,
    required String otherUid,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;

    final chatId = chatIdFor(myUid, otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    final now = FieldValue.serverTimestamp();

    final myContactRef = _db.collection('users').doc(myUid).collection('contacts').doc(otherUid);
    final otherContactRef = _db.collection('users').doc(otherUid).collection('contacts').doc(myUid);

    final batch = _db.batch();

    batch.set(chatRef, {
      'participants': [myUid, otherUid],
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(msgRef, {
      'senderUid': myUid,
      'kind': 'text',
      'text': t,
      'createdAt': now,
    });

    batch.set(myContactRef, {
      'lastMessageText': t,
      'lastMessageAt': now,
      'hasUnread': false,
      'unreadCount': 0,
    }, SetOptions(merge: true));

    batch.set(otherContactRef, {
      'lastMessageText': t,
      'lastMessageAt': now,
      'hasUnread': true,
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> sendVoice({
    required String myUid,
    required String otherUid,
    required String filePath,
    required int? durationMs,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Voice file missing.');
    }

    final chatId = chatIdFor(myUid, otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    final now = FieldValue.serverTimestamp();

    final storagePath = 'chats/$chatId/voices/${msgRef.id}.m4a';
    final storageRef = _storage.ref(storagePath);

    await storageRef.putFile(
      file,
      SettableMetadata(contentType: 'audio/mp4'),
    );

    final myContactRef = _db.collection('users').doc(myUid).collection('contacts').doc(otherUid);
    final otherContactRef = _db.collection('users').doc(otherUid).collection('contacts').doc(myUid);

    final batch = _db.batch();

    batch.set(chatRef, {
      'participants': [myUid, otherUid],
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(msgRef, {
      'senderUid': myUid,
      'kind': 'voice',
      'storagePath': storagePath,
      'durationMs': durationMs,
      'createdAt': now,
    });

    batch.set(myContactRef, {
      'lastMessageText': '🎤 Voice message',
      'lastMessageAt': now,
      'hasUnread': false,
      'unreadCount': 0,
    }, SetOptions(merge: true));

    batch.set(otherContactRef, {
      'lastMessageText': '🎤 Voice message',
      'lastMessageAt': now,
      'hasUnread': true,
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// ChatView calls this to play voice notes.
  Future<String> getVoiceUrl(String storagePath) async {
    return _storage.ref(storagePath).getDownloadURL();
  }

  Future<void> markRead({
    required String myUid,
    required String otherUid,
  }) async {
    final myContactRef = _db.collection('users').doc(myUid).collection('contacts').doc(otherUid);
    await myContactRef.set(
      {'hasUnread': false, 'unreadCount': 0},
      SetOptions(merge: true),
    );
  }
}
