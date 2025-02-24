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

/// A reporter that outputs comparison results to the command line.
///
/// This class reads and compares two files (approved and received) line by line,
/// highlighting the differences in color-coded format.
class CommandLineReporter implements Reporter {
  /// Default constructor for `CommandLineReporter`.
  const CommandLineReporter();

  @override
  void report(String approvedPath, String receivedPath, {String? message}) {
    try {
      final buffer = StringBuffer(message ?? "Differences:\n");

      final approvedLines = _readFileLines(approvedPath);
      final receivedLines = _readFileLines(receivedPath);

      final maxLines = max(approvedLines.length, receivedLines.length);

      for (var i = 0; i < maxLines; i++) {
        final approvedLine = i < approvedLines.length ? approvedLines[i] : "";
        final receivedLine = i < receivedLines.length ? receivedLines[i] : "";

        if (approvedLine != receivedLine) {
          _appendDifference(buffer, i + 1, approvedLine, receivedLine);
        }
      }

      if (buffer.isNotEmpty) {
        ApprovalLogger.exception(buffer.toString());
      }
    } catch (e) {
      // Logging and rethrowing to preserve error stack trace
      ApprovalLogger.exception("Error while reporting differences: \$e");
      rethrow;
    }
  }

  /// Reads the content of a file and returns a list of its lines.
  List<String> _readFileLines(String filePath) =>
      ApprovalUtils.readFile(filePath).split('\n');

  /// Appends a formatted difference to the provided buffer.
  void _appendDifference(
      StringBuffer buffer, int lineNumber, String approved, String received) {
    buffer.writeln(
      '${ApprovalUtils.lines(20)} Difference at line $lineNumber ${ApprovalUtils.lines(20)}\n',
    );
    buffer.writeln('Approved file, line $lineNumber: '
        '${_highlightDifference(approved, received, isApprovedFile: true)}');
    buffer.writeln('Received file, line $lineNumber: '
        '${_highlightDifference(approved, received)}');
  }

  /// Highlights differences between the approved and received lines.
  ///
  /// Uses `DiffMatchPatch` to compute the differences and applies ANSI color
  /// codes to highlight insertions (red) and deletions (green).
  String _highlightDifference(
    String approvedLine,
    String receivedLine, {
    bool isApprovedFile = false,
  }) {
    final differ = DiffMatchPatch();
    final diffs = differ.diff_main(approvedLine, receivedLine);
    differ.diff_cleanupSemantic(diffs);

    return diffs.map((diff) {
      return switch (diff.operation) {
        Operation.insert =>
          isApprovedFile ? '' : '\x1B[41m${diff.text}\x1B[0m\x1B[31m',
        Operation.delete =>
          isApprovedFile ? '\x1B[32m${diff.text}\x1B[31m' : '',
        Operation.equal => diff.text,
      };
    }).join();
  }
}
