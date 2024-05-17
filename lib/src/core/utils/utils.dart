part of '../../../approval_tests.dart';

// Define utility class for approval related operations. It contains methods for converting string cases and retrieving directory or file path.
final class ApprovalUtils {
  static AnsiPen hexToAnsiPen(String hex) {
    final int red = int.parse(hex.substring(0, 2), radix: 16);
    final int green = int.parse(hex.substring(2, 4), radix: 16);
    final int blue = int.parse(hex.substring(4, 6), radix: 16);

    final AnsiPen pen = AnsiPen()
      ..rgb(r: red / 255, g: green / 255, b: blue / 255);
    return pen;
  }

  /// Computes the Cartesian product of a list of lists.
  static Iterable<List<T>> cartesianProduct<T>(List<List<T>> lists) {
    try {
      Iterable<List<T>> result = [[]];
      for (final list in lists) {
        result = result.expand((x) => list.map((y) => [...x, y]));
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Property that gets the file path of the current file.
  static String get filePath {
    final stackTraceString = StackTrace.current.toString();
    final uriRegExp = RegExp(r'file:\/\/\/([^:]*):');

    final match = uriRegExp.firstMatch(stackTraceString);

    if (match != null) {
      final filePath = Uri.tryParse(match.group(0)!);
      return filePath!.toFilePath();
    } else {
      throw Exception('Could not find file path');
    }
  }

  static String readFile({
    required String path,
  }) {
    final File file = File(path);
    return file.readAsStringSync().trim();
  }

  static bool isFileExists(String path) {
    final File file = File(path);
    return file.existsSync();
  }

  static String lines(int count) => List.filled(count, '=').join();

  // Helper private method to check if contents of two files match
  static bool filesMatch(String approvedPath, String receivedPath) {
    try {
      // Read contents of the approved and received files
      final approved = ApprovalUtils.readFile(path: approvedPath)
          .replaceAll('\r\n', '\n')
          .trim();
      final received = ApprovalUtils.readFile(path: receivedPath)
          .replaceAll('\r\n', '\n')
          .trim();

      // Return true if contents of both files match exactly
      return approved.compareTo(received) == 0;
    } catch (_) {
      rethrow;
    }
  }

  static void deleteFile(String path) {
    try {
      final File file = File(path);
      final bool exists = file.existsSync();
      if (exists) {
        file.deleteSync();
      }
    } catch (_) {
      rethrow;
    }
  }
}
