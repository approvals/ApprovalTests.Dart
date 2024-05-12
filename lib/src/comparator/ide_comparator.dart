part of '../../approval_tests.dart';

/// `IDEComparator` is a class for comparing files using an `IDE`.
///
/// Available IDEs:
/// - `Visual Studio Code`
/// - `IntelliJ IDEA`
/// - `Android Studio`
final class IDEComparator extends Comparator {
  final ComparatorIDE ide;

  const IDEComparator({
    required this.ide,
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

      await Process.run(
        ide.command,
        [ide.argument, approvedPath, receivedPath],
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

  bool _fileExists(File file) => file.existsSync();

  void _throwFileException(String message) {
    throw IDEComparatorException(
      message: message,
      exception: null,
      stackTrace: null,
    );
  }
}
