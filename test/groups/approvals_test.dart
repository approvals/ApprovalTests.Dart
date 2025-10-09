import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';
import 'package:approval_tests/src/core/enums/file_type.dart';

void main() {
  group('Approvals.filePathForDeletion', () {
    test('returns approved path when namer provided', () {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final String dartPath = '${tempDir.path}/sample.dart';
      final ApprovalNamer namer = Namer(
        filePath: dartPath,
        addTestName: false,
      );

      final String resolvedPath = Approvals.filePathForDeletion(
        namer: namer,
        fileType: FileType.approved,
      );

      expect(resolvedPath, equals(namer.approved));
    });

    test('creates default namer when none provided', () {
      final String resolvedPath = Approvals.filePathForDeletion(
        namer: null,
        fileType: FileType.approved,
      );

      expect(resolvedPath, isNotEmpty);
      expect(resolvedPath, endsWith('.approved.txt'));
    });
  });
}
