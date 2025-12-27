import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity_program_v1/core/services/auth_repository.dart';
import 'package:productivity_program_v1/core/services/user_repo.dart';
import 'sign_in_page.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final firebaseUser = authSnap.data;

        if (firebaseUser == null) {
          return const SignInPage();
        }

        if (!firebaseUser.emailVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go('/verify-email');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return FutureBuilder(
          future: ref.read(userRepoProvider).getUser(firebaseUser.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              // single unified home
              context.go('/home');
            });

            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        );
      },
    );
  }
}
