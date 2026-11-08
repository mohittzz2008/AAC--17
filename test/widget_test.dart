
import 'package:flutter_test/flutter_test.dart';

import 'package:rover_command/main.dart';
import 'package:rover_command/shared/presentation/shell/rover_shell.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoverCommandApp());
    await tester.pumpAndSettle();
    
    expect(find.byType(RoverShell), findsOneWidget);
    expect(find.text('ROVER COMMAND'), findsOneWidget);
    expect(find.text('DEMO MODE'), findsOneWidget);
  });
}
