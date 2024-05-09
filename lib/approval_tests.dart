import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:mirrors';

import 'package:dcli/dcli.dart';
import 'package:talker/talker.dart';

part 'src/approvals.dart';
part 'src/writers/approval_text_writer.dart';
part 'src/core/logger/logger.dart';
part 'src/core/utils/utils.dart';
part 'src/core/options.dart';
part 'src/namer/namer.dart';
part 'src/comparator/comparator.dart';
part 'src/core/enums/comporator_ide.dart';
part 'src/comparator/command_line_comparator.dart';
part 'src/comparator/ide_comparator.dart';
part 'src/reporter/doesnt_match_exception.dart';
part 'src/core/utils/extensions.dart';
part 'src/core/utils/converter.dart';
part 'src/core/utils/executable_query.dart';
part 'src/namer/approval_number.dart';
