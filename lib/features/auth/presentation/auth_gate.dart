import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:productivity_program_v1/core/services/auth_repository.dart';
import 'package:productivity_program_v1/core/services/user_repo.dart';
import 'sign_in_page.dart';

/// AuthGate responsibility:
/// 1) Listen to Firebase auth (User?)
/// 2) If null → SignInPage
/// 3) If logged in → fetch AppUser from Firestore
/// 4) Redirect based on role
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authRepositoryProvider);

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = authSnap.data;

        // Not logged in → Sign In
        if (firebaseUser == null) {
          return const SignInPage();
        }

        // Logged in → resolve AppUser from Firestore
        return FutureBuilder(
          future: ref.read(userRepoProvider).getUser(firebaseUser.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final appUser = userSnap.data;

            if (appUser == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'User record not found.\nPlease create users/{uid} in Firestore.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Redirect ONCE after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (appUser.role == 'manager') {
                context.go('/manager');
              } else {
                context.go('/employee');
              }
            });

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
