import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerCommandLineReporterTests();

void registerCommandLineReporterTests() {
  group('CommandLineReporter', () {
    test('report logs exception when file read fails', () async {
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

      await expectLater(
        reporter.report(missingPath, missingPath),
        throwsA(isA<PathNotFoundException>()),
      );

      expect(loggedExceptions, hasLength(1));
      expect(loggedExceptions.first, isA<PathNotFoundException>());
    });

    test('report logs generic error for non-PathNotFoundException', () async {
      final List<Object> loggedExceptions = <Object>[];
      final reporter = CommandLineReporter(
        exceptionLogger: (Object exception, {StackTrace? stackTrace}) {
          loggedExceptions.add(exception);
        },
      );

      // Reading a directory as a file throws FileSystemException, not
      // PathNotFoundException, which exercises the else branch in catch.
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      await expectLater(
        reporter.report(tempDir.path, tempDir.path),
        throwsA(isA<FileSystemException>()),
      );

      expect(loggedExceptions, hasLength(1));
      expect(
        loggedExceptions.first,
        isA<String>()
            .having((s) => s, 'message', startsWith('Error while reporting')),
      );
    });
  });
}
