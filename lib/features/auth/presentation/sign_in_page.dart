import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity_program_v1/core/services/auth_prefs.dart';
import 'package:productivity_program_v1/core/services/auth_repository.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _email = TextEditingController(text: ' ');
  final _pass = TextEditingController(text: 'password');

  bool _rememberMe = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AuthPrefs.getRememberMe().then((v) {
      if (!mounted) return;
      setState(() => _rememberMe = v);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + small Sign Up button (top-right)
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Task Terminal',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/sign-up'),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Sign in using a seeded demo account.'),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pass,
                    decoration: const InputDecoration(labelText: 'Password'),
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
                      onPressed: _loading ? null : _signIn,
                      child: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign In'),
                    ),
                  ),

                  // Remember me (below sign-in option)
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      ),
                      const Text('Remember me'),
                    ],
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    'If redirect fails: create Firestore users/{uid} with role, displayName, teamId.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Persist user choice. If false, app will sign out on next launch (main.dart).
      await AuthPrefs.setRememberMe(_rememberMe);

      await ref.read(authRepositoryProvider).signIn(
            email: _email.text.trim(),
            password: _pass.text.trim(),
          );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
