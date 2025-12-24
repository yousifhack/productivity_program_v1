import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity_program_v1/features/auth/presentation/auth_gate.dart';
import 'package:productivity_program_v1/features/auth/presentation/sign_in_page.dart';
import 'package:productivity_program_v1/features/manager_dashboard/presentation/manager_dashboard_page.dart';
import 'package:productivity_program_v1/features/employee_tasks/presentation/employee_tasks_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/bootstrap',
    routes: [
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerDashboardPage(),
      ),
      GoRoute(
        path: '/employee',
        builder: (context, state) => const EmployeeTasksPage(),
      ),
    ],
  );
});
