import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerCommandLineReporterTests();

void registerCommandLineReporterTests() {
  group('CommandLineReporter', () {
    test('report logs exception when file read fails', () {
      final List<Object> loggedExceptions = <Object>[];
      final reporter = CommandLineReporter(
        exceptionLogger: (Object exception, {StackTrace? stackTrace}) {
          loggedExceptions.add(exception);
        },
      );

      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final String missingPath =
          '${tempDir.path}/command_line_reporter_missing.txt';

      expect(
        () => reporter.report(missingPath, missingPath),
        throwsA(isA<PathNotFoundException>()),
      );

      expect(loggedExceptions, hasLength(1));
      final String message = loggedExceptions.first.toString();
      expect(message, contains('Error while reporting differences:'));
      expect(message, contains('PathNotFoundException'));
    });
  });
}
