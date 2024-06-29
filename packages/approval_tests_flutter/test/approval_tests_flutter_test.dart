import 'package:approval_tests_flutter/approval_tests_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp _buildApp(Widget widget) => MaterialApp(
      home: MyCustomClass(
        widget: widget,
      ),
    );

class MyCustomClass extends StatelessWidget {
  const MyCustomClass({
    required this.widget,
    super.key,
  });

  final Widget widget;

  @override
  Widget build(BuildContext context) => Container(
        child: widget,
      );
}

enum MyEnumKeys {
  myKeyName,
}

void main() {
  setUpAll(() async {
    await ApprovalWidgets.setUpAll();
  });

  group('Approved test', () {
    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(const Text('Testing 1, 2, 3, 4')));
      await tester.pumpAndSettle();

      await tester.approvalTest();
    });
  });
}
