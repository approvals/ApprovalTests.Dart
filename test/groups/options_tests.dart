import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerOptionsTests();

void registerOptionsTests() {
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
      const options = Options(
        logResults: false,
        approveResult: true,
        missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
      );
      final updated = options.copyWith();

      expect(updated.logResults, isFalse);
      expect(updated.approveResult, isTrue);
      expect(
        updated.missingApprovedPolicy,
        MissingApprovedPolicy.writeReceivedAndFail,
      );
    });

    test('uses compatibility policy by default', () {
      const options = Options();

      expect(
        options.missingApprovedPolicy,
        MissingApprovedPolicy.createAndPass,
      );
    });

    test('replaces missing-approved policy explicitly', () {
      const options = Options();

      final updated = options.copyWith(
        missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
      );

      expect(
        updated.missingApprovedPolicy,
        MissingApprovedPolicy.writeReceivedAndFail,
      );
    });
  });
}
