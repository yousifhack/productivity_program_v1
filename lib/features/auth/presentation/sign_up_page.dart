import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity_program_v1/core/services/user_repo.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final p1 = _pass.text;
    final p2 = _pass2.text;

    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    if (p1.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: p1,
      );

      final user = cred.user!;
      await user.updateDisplayName(name);

      await ref.read(userRepoProvider).createUserDocIfMissing(
            uid: user.uid,
            displayName: name,
            email: email,
            role: 'employee',
            teamId: 'demo',
          );

      // Send verification email
      await user.sendEmailVerification();

      // Office-tablet friendly: sign out and return to Sign In.
      await FirebaseAuth.instance.signOut();

      if (mounted) context.go('/sign-in');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'email-already-in-use' => 'This email already exists. Please sign in.',
          'invalid-email' => 'Invalid email.',
          'weak-password' => 'Weak password.',
          'operation-not-allowed' => 'Email/Password sign-in is not enabled in Firebase.',
          _ => e.message ?? 'Sign up failed.',
        };
      });
    } catch (e) {
      setState(() => _error = 'Sign up failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/sign-in'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pass,
                    decoration: const InputDecoration(labelText: 'Create password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pass2,
                    decoration: const InputDecoration(labelText: 'Repeat password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _loading ? null : _signUp,
                      child: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
