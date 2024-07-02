import 'package:approval_tests_flutter/approval_tests_flutter.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async => await ApprovalWidgets.setUpAll());

  group('Example', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.approvalTest(
        description: 'should display 0',
        options: const Options(deleteReceivedFile: false),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.approvalTest(
        description: 'should display 1',
        options: const Options(deleteReceivedFile: false),
      );
    });
  });
}
