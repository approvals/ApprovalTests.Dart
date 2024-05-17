part of '../../../approval_tests.dart';

/// `DiffReporter` is a class for reporting the comparison results using a `Diff Tool`.
class DiffReporter implements Reporter {
  final ComparatorIDE ide;
  final DiffInfo? customDiffInfo;

  const DiffReporter({
    this.ide = ComparatorIDE.vsCode,
    this.customDiffInfo,
  });

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    final DiffInfo diffInfo = _diffInfo;

    try {
      await Future.wait([
        _checkFileExists(approvedPath),
        _checkFileExists(receivedPath),
      ]);

      await Process.run(
        diffInfo.command,
        [diffInfo.arg, approvedPath, receivedPath],
      );
    } catch (e, st) {
      if (e is PathNotFoundException) {
        rethrow;
      }
      throw IDEComparatorException(
        message: 'Error during comparison via ${ide.name}. Please try check path to IDE. \n Current path: ${diffInfo.command}.',
        exception: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _checkFileExists(String path) async {
    if (!ApprovalUtils.isFileExists(path)) {
      throw PathNotFoundException(path, const OSError('File not found'));
    }
  }

  DiffInfo get _diffInfo {
    if (customDiffInfo != null) {
      return customDiffInfo!;
    } else {
      if (Platform.isMacOS) {
        return switch (ide) {
          ComparatorIDE.vsCode => MacDiffTools.visualStudioCode,
          ComparatorIDE.studio => MacDiffTools.androidStudio,
        };
      } else if (Platform.isWindows) {
        return switch (ide) {
          ComparatorIDE.vsCode => WindowsDiffTools.visualStudioCode,
          ComparatorIDE.studio => WindowsDiffTools.androidStudio,
        };
      } else {
        return switch (ide) {
          ComparatorIDE.vsCode => LinuxDiffTools.visualStudioCode,
          ComparatorIDE.studio => LinuxDiffTools.androidStudio,
        };
      }
    }
  }
}
