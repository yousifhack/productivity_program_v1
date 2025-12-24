# Task Terminal (MVP scaffold)

Tablet-first Flutter app for a kiosk-style task execution surface. Stack: Flutter, Firebase (core/auth/firestore), Riverpod, go_router.

## Running
1) `flutter pub get`
2) Configure Firebase (`flutterfire configure`) and add generated `firebase_options.dart`.
3) `flutter run -d chrome` or Android emulator/tablet.

## Structure
- `lib/app.dart`: Theme + router wiring.
- `lib/core`: models, utilities (breakpoints, time, constants), widgets (responsive shell, task cards), services (repo interfaces for auth/tasks/comments/events/AI).
- `lib/features`: auth gate + sign-in, manager dashboard mock, employee tasks mock, task detail shell, AI modal stubs, settings.

Day 1 focus: skeleton routing/theme, responsive layout helpers, Firestore schema constants, repository interfaces, and demo UI placeholders. Next steps: hook real Firestore streams, auth profile hydration, task CRUD flows, SLA timers, AI Cloud Functions.
