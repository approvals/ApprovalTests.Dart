part of '../../../approval_tests.dart';

/// `CommandLineReporter` is a class for reporting the comparison results using the command line.
class CommandLineReporter implements Reporter {
  const CommandLineReporter();

  @override
  void report(String approvedPath, String receivedPath, {String? message}) {
    try {
      final StringBuffer buffer = StringBuffer(message ?? "Differences:\n");

      final List<String> approvedLines =
          ApprovalUtils.readFile(path: approvedPath).split('\n');
      final List<String> receivedLines =
          ApprovalUtils.readFile(path: receivedPath).split('\n');

      final int maxLines = max(approvedLines.length, receivedLines.length);

      for (int i = 0; i < maxLines; i++) {
        final String approvedLine =
            i < approvedLines.length ? approvedLines[i] : "";
        final String receivedLine =
            i < receivedLines.length ? receivedLines[i] : "";

        if (approvedLine != receivedLine) {
          buffer.writeln(
            '${ApprovalUtils.lines(20)} Difference at line ${i + 1} ${ApprovalUtils.lines(20)} \n',
          );
          buffer.writeln(
            'Approved file, line ${i + 1}: ${_highlightDifference(approvedLine, receivedLine, isApprovedFile: true)}',
          );
          buffer.writeln(
            'Received file, line ${i + 1}: ${_highlightDifference(approvedLine, receivedLine)}',
          );
        }
      }

      if (buffer.isNotEmpty) {
        ApprovalLogger.exception(buffer.toString());
      }
    } catch (e) {
      rethrow;
    }
  }

  String _highlightDifference(
    String approvedLine,
    String receivedLine, {
    bool isApprovedFile = false,
  }) {
    // Create a new instance of DiffMatchPatch
    final differ = DiffMatchPatch();

    // Compute the difference between the Approved and Received lines. [diffs] is a List of Diff objects.
    final diffs = differ.diff_main(approvedLine, receivedLine);

    // Reduce the number of edits by eliminating semantically trivial equalities. [diffs] is a List of Diff objects.
    differ.diff_cleanupSemantic(diffs);

    return diffs.map((diff) {
      if (diff.operation == Operation.insert && !isApprovedFile) {
        // Red for insertions in the Received file
        return '\x1B[41m${diff.text}\x1B[0m\x1B[31m';
      } else if (diff.operation == Operation.delete && isApprovedFile) {
        // Green for deletions in the Approved file
        return '\x1B[32m${diff.text}\x1B[31m';
      } else if (diff.operation == Operation.equal) {
        // No highlighting for equal parts
        return diff.text;
      } else {
        // For any unexpected cases
        return '';
      }
    }).join();
  }
}
