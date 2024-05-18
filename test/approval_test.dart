// Import third-party packages
import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

// Import project-specific dependencies
import 'models/item.dart';
import 'queries/db_request_query.dart';

part 'utils/helper.dart';
part 'constants/lines.dart';
part 'mock/testable_file_path_extractor.dart';
part 'mock/testable_platform_wrapper.dart';
part 'groups/diff_tools_tests.dart';
part 'groups/exception_tests.dart';
part 'groups/minor_tests.dart';
part 'groups/verify_tests.dart';

void main() {
  /// ================== Init fields ==================

  const helper = ApprovalTestHelper();
  const dbQuery = DatabaseRequestQuery("1");
  const lines25 = _Lines.lines25;
  const lines30 = _Lines.lines30;
  final dateTime = DateTime(2021, 10, 10, 10, 10, 10);

  /// ================== Set up ==================

  setUpAll(() {
    ApprovalLogger.warning("$lines30 Tests are starting $lines30");
  });

  /// ================== Approvals: verify methods ==================

  verifyTests(helper: helper, lines25: lines25, dbQuery: dbQuery);

  /// ================== Approvals: test for exceptions ==================

  exceptionTests(helper: helper, lines25: lines25);

  /// ================== Approvals: minor tests ==================

  minorTests(helper: helper, dateTime: dateTime, lines25: lines25);

  /// ================== Approvals: test for Diff Tools ==================

  diffToolsTests(lines25: lines25);

  /// ================== Tear down ==================

  tearDownAll(() {
    ApprovalLogger.warning("$lines30 All tests are done $lines30");
  });
}
