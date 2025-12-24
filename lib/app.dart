import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';

class TaskTerminalApp extends ConsumerWidget {
  const TaskTerminalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Task Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}

// This fixes any old code that still references MyApp
class MyApp extends TaskTerminalApp {
  const MyApp({super.key});
}
