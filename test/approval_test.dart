import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import 'groups/approvals_test.dart' as approvals_tests;
import 'groups/command_line_reporter_test.dart' as command_line_reporter_tests;
import 'groups/converter_tests.dart' as converter_tests;
import 'groups/diff_tools_tests.dart' as diff_tools_tests;
import 'groups/exception_tests.dart' as exception_tests;
import 'groups/git_reporter_test.dart' as git_reporter_tests;
import 'groups/minor_tests.dart' as minor_tests;
import 'groups/namer.dart' as namer_tests;
import 'groups/options_tests.dart' as options_tests;
import 'groups/reporter_arguments_test.dart' as reporter_arguments_tests;
import 'groups/verify_tests.dart' as verify_tests;

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

  /// ================== Approvals: core behavior ==================

  approvals_tests.registerApprovalsTests();
  converter_tests.registerConverterTests();
  options_tests.registerOptionsTests();

  /// ================== Approvals: verify methods ==================

  verify_tests.registerVerifyTests();

  /// ================== Approvals: test for exceptions ==================

  exception_tests.registerExceptionTests();

  /// ================== Approvals: minor tests ==================

  minor_tests.registerMinorTests();

  /// ================== Approvals: reporter suites ==================

  command_line_reporter_tests.registerCommandLineReporterTests();
  reporter_arguments_tests.registerReporterArgumentsTests();
  git_reporter_tests.registerGitReporterTests();

  /// ================== Approvals: test for Diff Tools ==================

  diff_tools_tests.registerDiffToolTests();

  /// ================== Approvals: Namer tests ==================

  namer_tests.registerNamerTests();

  /// ================== Tear down ==================

  tearDownAll(() {
    ApprovalLogger.warning("$lines30 All tests are done $lines30");
  });
}
