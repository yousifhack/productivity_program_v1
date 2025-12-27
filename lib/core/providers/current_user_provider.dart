import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final displayNameProvider = Provider<String>((ref) {
  final u = ref.watch(firebaseUserProvider);
  final name = u?.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  return 'User';
});
