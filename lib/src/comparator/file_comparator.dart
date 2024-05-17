part of '../../approval_tests.dart';

/// A class `FileComparator` that implements the `Comparator` interface.
/// This class is used to compare the content of two files.
final class FileComparator implements Comparator {
  const FileComparator();

  @override
  bool compare({
    required String approvedPath,
    required String receivedPath,
    bool isLogError = true,
  }) {
    try {
      final approved = ApprovalUtils.readFile(path: approvedPath)
          .replaceAll('\r\n', '\n')
          .trim();
      final received = ApprovalUtils.readFile(path: receivedPath)
          .replaceAll('\r\n', '\n')
          .trim();

      // Return true if contents of both files match exactly
      return approved.compareTo(received) == 0;
    } catch (e) {
      if (isLogError) {
        ApprovalLogger.exception(e.toString());
      }
      rethrow;
    }
  }
}
