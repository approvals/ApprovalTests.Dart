import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:mirrors';

import 'package:talker/talker.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:test_api/src/backend/invoker.dart' show Invoker;

part 'src/approvals.dart';
part 'src/writers/approval_text_writer.dart';

part 'src/core/logger/logger.dart';
part 'src/core/utils/utils.dart';
part 'src/core/options.dart';
part 'src/core/approval_writer.dart';
part 'src/core/enums/comporator_ide.dart';
part 'src/core/utils/converter.dart';
part 'src/core/utils/executable_query.dart';
part 'src/core/scrubber.dart';
part 'src/scrubbers/date_scrubber.dart';
part 'src/scrubbers/nothing_scrubber.dart';
part 'src/scrubbers/reg_exp_scrubber.dart';
part 'src/core/extensions/approval_string_extensions.dart';

part 'src/namer/namer.dart';
part 'src/core/approval_number.dart';
part 'src/namer/file_namer_options.dart';

part 'src/comparator/comparator.dart';
part 'src/comparator/command_line_comparator.dart';
part 'src/comparator/ide_comparator.dart';
part 'src/comparator/diff_info.dart';
part 'src/comparator/diff_tools.dart';

part 'src/exceptions/doesnt_match_exception.dart';
part 'src/exceptions/command_line_comparator_exception.dart';
part 'src/exceptions/ide_comparator_exception.dart';
