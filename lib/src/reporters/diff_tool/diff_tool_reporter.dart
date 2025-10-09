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

/// `DiffReporter` is a class for reporting the comparison results using a `Diff Tool`.
class DiffReporter implements Reporter {
  final ComparatorIDE ide;
  final DiffInfo? customDiffInfo;

  /// Platform wrapper for testing purposes.
  final IPlatformWrapper platformWrapper;

  const DiffReporter({
    this.ide = ComparatorIDE.vsCode,
    this.customDiffInfo,
    this.platformWrapper = const PlatformWrapper(),
  });

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    final DiffInfo diffInfo = defaultDiffInfo;

    try {
      await Future.wait([
        _checkFileExists(approvedPath),
        _checkFileExists(receivedPath),
      ]);

      final args = _expandArgs(diffInfo.arg)
        ..addAll([approvedPath, receivedPath]);

      await Process.run(
        diffInfo.command,
        args,
      );
    } catch (e, st) {
      if (e is PathNotFoundException) {
        ApprovalLogger.exception(e, stackTrace: st);
        rethrow;
      }
      if (e is ProcessException) {
        final ProcessResult result =
            await Process.run(ApprovalUtils.commandWhere, [diffInfo.command]);
        ApprovalLogger.exception(
          'Error during comparison via ${ide.name}. Please try check path of IDE. \n Current path: ${diffInfo.command} with arg: "${diffInfo.arg}" \n Path to IDE (${Platform.operatingSystem}): ${result.stdout} \n Please, add path to customDiffInfo.',
          stackTrace: st,
        );
      }
      rethrow;
    }
  }

  Future<void> _checkFileExists(String path) async {
    if (!ApprovalUtils.isFileExists(path)) {
      throw PathNotFoundException(
        path,
        const OSError('File not found'),
        'From DiffToolReporter: File not found at path: [$path]. Please check the path and try again.',
      );
    }
  }

  DiffInfo get defaultDiffInfo {
    if (customDiffInfo != null) {
      return customDiffInfo!;
    } else {
      if (platformWrapper.isMacOS) {
        return switch (ide) {
          ComparatorIDE.vsCode => MacDiffTools.visualStudioCode,
          ComparatorIDE.studio => MacDiffTools.androidStudio,
        };
      } else if (platformWrapper.isWindows) {
        return switch (ide) {
          ComparatorIDE.vsCode => WindowsDiffTools.visualStudioCode,
          ComparatorIDE.studio => WindowsDiffTools.androidStudio,
        };
      } else if (platformWrapper.isLinux) {
        return switch (ide) {
          ComparatorIDE.vsCode => LinuxDiffTools.visualStudioCode,
          ComparatorIDE.studio => LinuxDiffTools.androidStudio,
        };
      }
    }
    throw NoDiffToolException(
      message:
          'Diff tool is not supported on this platform. Please add customDiffInfo.',
      stackTrace: StackTrace.current,
    );
  }

  bool get isReporterAvailable {
    try {
      final diffInfo = defaultDiffInfo;
      return ApprovalUtils.isFileExists(diffInfo.command);
    } catch (e) {
      return false;
    }
  }

  /// Visible for testing to validate arg parsing without invoking a diff tool.
  @visibleForTesting
  List<String> expandArgsForTesting(String arg) {
    return _expandArgs(arg);
  }

  List<String> _expandArgs(String arg) {
    final trimmed = arg.trim();
    if (trimmed.isEmpty) {
      return <String>[];
    }
    return trimmed.split(RegExp(r'\s+'));
  }
}
