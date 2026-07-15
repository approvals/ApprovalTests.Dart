/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

part of '../../../approval_tests.dart';

/// Provides the package's console diagnostics.
final class ApprovalLogger {
  final ISpectLogger _logger;

  static final ApprovalLogger _instance = ApprovalLogger._internal(
    ISpectLogger(
      options: ISpectLoggerOptions(
        useHistory: false,
        customColors: {
          ISpectLogType.error.key: ApprovalUtils.hexToAnsiPen('de7979'),
          ISpectLogType.exception.key: ApprovalUtils.hexToAnsiPen('de7979'),
        },
      ),
    ),
  );

  ApprovalLogger._internal(this._logger);

  /// Logs a diagnostic message.
  static void log(String message) => _instance._logger.debug(message);

  /// Logs a successful operation.
  static void success(String message) => _instance._logger.good(message);

  /// Logs a warning.
  static void warning(String message) => _instance._logger.warning(message);

  /// Logs an exception without discarding its original stack trace.
  static void exception(Object exception, {StackTrace? stackTrace}) =>
      _instance._logger.handle(
        exception: exception,
        stackTrace: stackTrace,
      );
}
