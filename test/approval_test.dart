import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import 'groups/diff_tools_tests.dart' as diff_tools_tests;
import 'groups/exception_tests.dart' as exception_tests;
import 'groups/minor_tests.dart' as minor_tests;
import 'groups/verify_tests.dart' as verify_tests;
import 'groups/namer.dart' as namer_tests;

import 'models/item.dart';
import 'queries/db_request_query.dart';

part 'constants/lines.dart';

part 'mock/testable_file_path_extractor.dart';
part 'mock/testable_platform_wrapper.dart';
part 'utils/helper.dart';

/// ================== Init fields ==================

const helper = ApprovalTestHelper();
const lines25 = Lines.lines25;
const dbQuery = DatabaseRequestQuery("1");
const lines30 = Lines.lines30;

void main() {
  /// ================== Set up ==================

  setUpAll(() {
    ApprovalLogger.warning("$lines30 Tests are starting $lines30");
  });

  /// ================== Approvals: verify methods ==================

  verify_tests.main();

  /// ================== Approvals: test for exceptions ==================

  exception_tests.main();

  /// ================== Approvals: minor tests ==================

  minor_tests.main();

  /// ================== Approvals: test for Diff Tools ==================

  diff_tools_tests.main();

  /// ================== Approvals: Namer tests ==================

  namer_tests.main();

  /// ================== Tear down ==================

  tearDownAll(() {
    ApprovalLogger.warning("$lines30 All tests are done $lines30");
  });
}
