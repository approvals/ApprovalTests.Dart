part of '../../../approval_tests.dart';

/// `CommandLineReporter` is a class for reporting the comparison results using the command line.
class CommandLineReporter implements Reporter {
  const CommandLineReporter();

  @override
  void report(String approvedPath, String receivedPath, {String? message}) {
    try {
      final String approvedContent = ApprovalUtils.readFile(path: approvedPath);
      final String receivedContent = ApprovalUtils.readFile(path: receivedPath);

      final StringBuffer buffer = StringBuffer(message ?? "Differences:\n");
      final List<String> approvedLines = approvedContent.split('\n');
      final List<String> receivedLines = receivedContent.split('\n');

      final int maxLines = max(approvedLines.length, receivedLines.length);
      for (int i = 0; i < maxLines; i++) {
        final String approvedLine =
            i < approvedLines.length ? approvedLines[i] : "";
        final String receivedLine =
            i < receivedLines.length ? receivedLines[i] : "";

        if (approvedLine != receivedLine) {
          buffer.writeln(
            '${ApprovalUtils.lines(20)} Difference at line ${i + 1} ${ApprovalUtils.lines(20)}',
          );
          buffer.writeln(
            'Approved file: ${_highlightDifference(approvedLine, receivedLine)}',
          );
          buffer.writeln(
            'Received file: ${_highlightDifference(receivedLine, approvedLine)}',
          );
        }
      }

      if (buffer.isNotEmpty) {
        final String reportMessage = buffer.toString();
        ApprovalLogger.exception(reportMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  String _highlightDifference(String line1, String line2) {
    final int minLength = min(line1.length, line2.length);
    final StringBuffer highlighted = StringBuffer();

    for (int i = 0; i < minLength; i++) {
      if (line1[i] != line2[i]) {
        highlighted.write(_Colorize(line1[i]).apply(_LogColorStyles.bgRed));
      } else {
        highlighted.write(_Colorize(line1[i]).apply(_LogColorStyles.red));
      }
    }

    return highlighted.toString();
  }
}
