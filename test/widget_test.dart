import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity_program_v1/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskTerminalApp()));
    await tester.pump();
    expect(find.byType(TaskTerminalApp), findsOneWidget);
  });
}
