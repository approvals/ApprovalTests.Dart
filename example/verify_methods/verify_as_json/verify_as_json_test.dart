import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../../../test/approval_test.dart';

void main() {
  test('Verify JSON output of an object', () {
    Approvals.verifyAsJson(
      ApprovalTestHelper.jsonItem,
      options: const Options(deleteReceivedFile: true),
    );
  });
}
