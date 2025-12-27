import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _loading = false;
  String? _msg;

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _msg = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _msg = 'You are signed out.');
        return;
      }
      await user.sendEmailVerification();
      setState(() => _msg = 'Verification email sent.');
    } catch (e) {
      setState(() => _msg = 'Failed to send email: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _iVerified() async {
    setState(() {
      _loading = true;
      _msg = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _msg = 'You are signed out.');
        return;
      }

      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;

      if (refreshed != null && refreshed.emailVerified) {
        if (mounted) context.go('/bootstrap');
        return;
      }

      setState(() => _msg = 'Not verified yet. Click the link in your email, then try again.');
    } catch (e) {
      setState(() => _msg = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/sign-in');
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
                  const Text(
                    'Verify your email',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'We sent a verification link to your email.\nOpen it, click the link, then come back here.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (_msg != null) ...[
                    Text(
                      _msg!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _msg!.startsWith('Failed') || _msg!.startsWith('Error') ? Colors.red : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _loading ? null : _iVerified,
                      child: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('I verified'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : _resend,
                          child: const Text('Resend email'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: _loading ? null : _signOut,
                          child: const Text('Sign out'),
                        ),
                      ),
                    ],
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
