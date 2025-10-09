import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  group('Options copyWith', () {
    test('accepts ApprovalNamer implementations', () {
      final options = const Options();
      final updated = options.copyWith(
        namer: IndexedNamer(
          filePath: 'test${Platform.pathSeparator}options_test.dart',
        ),
      );

      expect(updated.namer, isA<IndexedNamer>());
    });

    test('keeps previous values when parameters omitted', () {
      const options = Options(logResults: false, approveResult: true);
      final updated = options.copyWith();

      expect(updated.logResults, isFalse);
      expect(updated.approveResult, isTrue);
    });
  });
}
