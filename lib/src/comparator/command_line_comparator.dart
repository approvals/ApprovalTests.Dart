part of '../../approval_tests.dart';

/// `CommandLineComparator` it is for comparing files via Command Line.
///
/// This method compares the content of two files line by line and prints the differences in the console.
final class CommandLineComparator extends ComparatorImp {
  const CommandLineComparator();

  @override
  Future<void> compare({
    required String approvedPath,
    required String receivedPath,
    bool isLogError = true,
  }) async {
    try {
      final String approvedContent = ApprovalUtils.readFile(path: approvedPath);
      final String receivedContent = ApprovalUtils.readFile(path: receivedPath);

      final StringBuffer buffer = StringBuffer("Differences:\n");
      final List<String> approvedLines = approvedContent.split('\n');
      final List<String> receivedLines = receivedContent.split('\n');

      final int maxLines = max(approvedLines.length, receivedLines.length);
      for (int i = 0; i < maxLines; i++) {
        if (i >= approvedLines.length ||
            i >= receivedLines.length ||
            approvedLines[i] != receivedLines[i]) {
          buffer.writeln(
            '${ApprovalUtils.lines(20)} Difference at line ${i + 1} ${ApprovalUtils.lines(20)}',
          );
          buffer.writeln(
            'Approved file: ${i < approvedLines.length ? approvedLines[i] : "No content"}',
          );
          buffer.writeln(
            'Received file: ${i < receivedLines.length ? receivedLines[i] : "No content"}',
          );
        }
      }

      if (buffer.isNotEmpty && isLogError) {
        final String message = buffer.toString();
        logError(exception: message.trim());
      }
    } catch (e, st) {
      if (isLogError) {
        logError(
          exception: 'Error during comparison via Command Line. Error: $e',
          stackTrace: st,
        );
      }
      rethrow;
    }
  }
}
