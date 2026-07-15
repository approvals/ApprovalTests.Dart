import 'dart:async';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('ApprovalLogger writes every severity and preserves stack traces', () {
    final output = <String>[];

    runZoned(
      () {
        ApprovalLogger.log('debug message');
        ApprovalLogger.success('success message');
        ApprovalLogger.warning('warning message');
        ApprovalLogger.exception(
          StateError('failure message'),
          stackTrace: StackTrace.fromString('original stack trace'),
        );
      },
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, line) => output.add(line),
      ),
    );

    final combinedOutput = output.join('\n');
    expect(combinedOutput, contains('debug message'));
    expect(combinedOutput, contains('success message'));
    expect(combinedOutput, contains('warning message'));
    expect(combinedOutput, contains('failure message'));
    expect(combinedOutput, contains('original stack trace'));
  });
}
