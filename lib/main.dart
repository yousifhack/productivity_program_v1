import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/services/auth_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // If "Remember me" is OFF, force sign-out on app launch.
  final remember = await AuthPrefs.getRememberMe();
  if (!remember) {
    await FirebaseAuth.instance.signOut();
  }

  await WakelockPlus.enable();

  runApp(const ProviderScope(child: MyApp()));
}
