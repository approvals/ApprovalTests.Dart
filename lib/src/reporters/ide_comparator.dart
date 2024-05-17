part of '../../approval_tests.dart';

/// `IDEComparator` is a class for comparing files using an `IDE`.
///
/// Available IDEs:
/// - `Visual Studio Code`
/// - `Android Studio`
final class IDEComparator extends Comparator {
  final ComparatorIDE ide;
  final DiffInfo? customDiffInfo;

  const IDEComparator({
    this.ide = ComparatorIDE.vsCode,
    this.customDiffInfo,
  });

  @override
  Future<void> compare({
    required String approvedPath,
    required String receivedPath,
    bool isLogError = true,
  }) async {
    try {
      final File approvedFile = File(approvedPath);
      final File receivedFile = File(receivedPath);

      if (!_fileExists(approvedFile) || !_fileExists(receivedFile)) {
        _throwFileException(
          'Files not found for comparison. Please check the paths: \n\n Approved file path: $approvedPath, \n\n Received file path: $receivedPath.',
        );
      }
      final DiffInfo diffInfo = _diffInfo;

      await Process.run(
        diffInfo.command,
        [diffInfo.arg, approvedPath, receivedPath],
      );
    } catch (e, st) {
      throw IDEComparatorException(
        message:
            'Error during comparison via ${ide.name}. Please try restart your IDE.',
        exception: e,
        stackTrace: st,
      );
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

  bool _fileExists(File file) => file.existsSync();

  void _throwFileException(String message) {
    throw IDEComparatorException(
      message: message,
      exception: null,
      stackTrace: StackTrace.current,
    );
  }
}
