part of '../../approval_tests.dart';

/// `IDEComparator` is a class for comparing files using an `IDE`.
///
/// Available IDEs:
/// - `Visual Studio Code`
/// - `IntelliJ IDEA`
/// - `Android Studio`
final class IDEComparator extends ComparatorImp {
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
      await Process.run(
        ide.command,
        [ide.argument, approvedPath, receivedPath],
      );
    } catch (e, st) {
      if (isLogError) {
        logError(
          exception:
              'Error during comparison via ${ide.name}. Please restart your IDE. Error: $e',
          stackTrace: st,
        );
      }
      rethrow;
    }
  }
}
