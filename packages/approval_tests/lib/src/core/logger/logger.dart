/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

part of '../../../approval_tests.dart';

/// `ApprovalLogger` is a class that provides methods to log messages with different log levels.
final class ApprovalLogger {
  // Private property holding the instance of Logger
  final Talker _logger;

  // Singleton instance of AppLogger
  static final ApprovalLogger _instance = ApprovalLogger._internal(
    Talker(
      logger: TalkerLogger(settings: TalkerLoggerSettings(maxLineWidth: 130)),
      settings: TalkerSettings(
        titles: _defaultTitles,
        colors: {
          TalkerLogType.critical: AnsiPen()..red(),
          TalkerLogType.warning: AnsiPen()..yellow(),
          TalkerLogType.verbose: AnsiPen()..gray(),
          TalkerLogType.info: AnsiPen()..cyan(),
          TalkerLogType.debug: AnsiPen()..gray(),
          TalkerLogType.error: ApprovalUtils.hexToAnsiPen('de7979'),
          TalkerLogType.exception: ApprovalUtils.hexToAnsiPen('de7979'),
        },
      ),
    ),
  );

  // Private internal constructor for initializing the Logger instance
  ApprovalLogger._internal(this._logger);

  // Define constant title with ANSI color codes.
  static const _approvalTitle = "ApprovalTests";

  // Define default titles for different log types.
  static const _defaultTitles = {
    TalkerLogType.critical: '💀 $_approvalTitle',
    TalkerLogType.warning: '🟡 $_approvalTitle',
    TalkerLogType.verbose: '🐛 $_approvalTitle',
    TalkerLogType.info: '🔍 $_approvalTitle',
    TalkerLogType.debug: '🐛 $_approvalTitle',
    TalkerLogType.error: '🔴 $_approvalTitle',
    TalkerLogType.exception: '🔴 $_approvalTitle',
  };

  /// `log` method to log messages with debug log level.
  static void log(String message) => _instance._logger.debug(message);

  /// `info` method to log messages with success log level.
  static void success(String message) =>
      _instance._logger.logTyped(_SuccessLog(message));

  /// `warning` method to log messages with warning log level.
  static void warning(String message) => _instance._logger.warning(message);

  /// `exception` method to handle exceptions and log them with error log level.
  static void exception(Object exception, {StackTrace? stackTrace}) {
    final message = exception.toString();
    _instance._logger.error(
      message,
      null,
      stackTrace,
    );
  }
}

/// `_SuccessLog` is a class that extends `TalkerLog` to provide success logs.
class _SuccessLog extends TalkerLog {
  _SuccessLog(String super.message);

  /// Your custom log title
  @override
  String get title => '🟢 ${ApprovalLogger._approvalTitle}';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..xterm(121);
}
