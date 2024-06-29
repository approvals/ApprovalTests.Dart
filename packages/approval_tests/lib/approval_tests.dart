// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diff_match_patch2/diff_match_patch.dart';
import 'package:talker/talker.dart';
import 'package:test_api/src/backend/invoker.dart' show Invoker;

part 'src/approvals.dart';
part 'src/comparator/file_comparator.dart';
part 'src/core/approval_number.dart';
part 'src/core/approval_writer.dart';
part 'src/core/comparator.dart';
part 'src/core/enums/comporator_ide.dart';
part 'src/core/extensions/approval_string_extensions.dart';
part 'src/core/utils/file_path_extractor.dart';
part 'src/core/logger/logger.dart';
part 'src/core/options.dart';
part 'src/core/platform_wrapper.dart';
part 'src/core/reporter.dart';
part 'src/core/scrubber.dart';
part 'src/core/stack_trace_fetcher/fetcher.dart';
part 'src/core/stack_trace_fetcher/stack_trace_fetcher.dart';
part 'src/core/utils/converter.dart';
part 'src/core/utils/executable_query.dart';
part 'src/core/utils/utils.dart';
part 'src/exceptions/doesnt_match_exception.dart';
part 'src/exceptions/file_not_found_exception.dart';
part 'src/exceptions/no_diff_tool_exception.dart';
part 'src/namer/file_namer_options.dart';
part 'src/namer/namer.dart';
part 'src/reporters/command_line/command_line_reporter.dart';
part 'src/reporters/diff_tool/diff_info.dart';
part 'src/reporters/diff_tool/diff_tool_reporter.dart';
part 'src/reporters/diff_tool/diff_tools.dart';
part 'src/scrubbers/date_scrubber.dart';
part 'src/scrubbers/nothing_scrubber.dart';
part 'src/scrubbers/reg_exp_scrubber.dart';
part 'src/writers/approval_text_writer.dart';
part 'src/reporters/git.dart';
