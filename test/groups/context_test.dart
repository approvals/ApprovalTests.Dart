import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() => registerContextTests();

/// Namer without the [ContextAwareNamer] capability, mirroring a pre-1.7.0
/// custom namer.
final class _ContextlessNamer implements ApprovalNamer {
  const _ContextlessNamer({required this.approved, required this.received});

  @override
  final String approved;
  @override
  final String received;

  @override
  bool get addTestName => false;
  @override
  String get approvedFileName => p.basename(approved);
  @override
  String get currentTestName => '';
  @override
  String? get description => null;
  @override
  String? get filePath => null;
  @override
  FileNamerOptions? get options => null;
  @override
  String get receivedFileName => p.basename(received);
  @override
  bool get useSubfolder => false;

  @override
  _ContextlessNamer copyWith({
    String? filePath,
    FileNamerOptions? options,
    bool? addTestName,
    String? description,
    bool? useSubfolder,
  }) =>
      this;
}

void registerContextTests() {
  group('ApprovalContext value |', () {
    setUpAll(() {
      ApprovalLogger.log("===== Group: ApprovalContext =====");
    });

    test('describes its source path and test name', () {
      const context = ApprovalContext(
        sourcePath: 'test/billing/invoice_test.dart',
        testName: 'renders a paid invoice',
      );

      expect(
        context.toString(),
        allOf(
          contains('test/billing/invoice_test.dart'),
          contains('renders a paid invoice'),
        ),
      );
    });

    test('rejects an empty source path', () {
      expect(
        () => ApprovalContext(sourcePath: ''),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ApprovalContext naming |', () {
    test('produces the same name as inferred naming', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_identity');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final filePath = p.join(tempDir.path, 'sample.dart');

      final inferred = Namer(filePath: filePath);
      final explicit = Namer(
        filePath: filePath,
        context: ApprovalContext(
          sourcePath: filePath,
          testName: inferred.currentTestName,
        ),
      );

      expect(explicit.approvedFileName, equals(inferred.approvedFileName));
      expect(explicit.received, equals(inferred.received));
    });

    test('an explicit test name overrides the ambient one', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_override');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final filePath = p.join(tempDir.path, 'sample.dart');

      final namer = Namer(
        filePath: filePath,
        context: ApprovalContext(
          sourcePath: filePath,
          testName: 'explicit name',
        ),
      );

      expect(
          namer.approvedFileName, equals('sample.explicit_name.approved.txt'));
    });

    test('keeps the ambient name when the context omits one', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_partial');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final filePath = p.join(tempDir.path, 'sample.dart');

      final namer = Namer(
        filePath: filePath,
        context: ApprovalContext(sourcePath: filePath),
      );

      expect(
        namer.approvedFileName,
        equals('sample.keeps_the_ambient_name_when_the_context_omits_one'
            '.approved.txt'),
      );
    });

    test('rejects a test name carrying a path separator', () {
      expect(
        () => const Namer(
          filePath: 'test/sample.dart',
          context: ApprovalContext(
            sourcePath: 'test/sample.dart',
            testName: 'a/b',
          ),
        ).approvedFileName,
        throwsA(isA<InvalidApprovalNameException>()),
      );
    });

    test('copyWith preserves and replaces the context', () {
      const original = ApprovalContext(sourcePath: 'a.dart', testName: 'one');
      const replacement =
          ApprovalContext(sourcePath: 'b.dart', testName: 'two');
      const namer = Namer(filePath: 'a.dart', context: original);

      expect(namer.copyWith(addTestName: false).context, same(original));
      expect(namer.copyWith(context: replacement).context, same(replacement));
    });
  });

  group('ApprovalContext without a test framework |', () {
    setUp(() => addTearDown(BaseNamer.resetAmbientTestName));

    test('fails with an actionable error when no name can be resolved', () {
      BaseNamer.ambientTestName = () => null;

      expect(
        () => const Namer(
          filePath: 'test/sample.dart',
          context: ApprovalContext(sourcePath: 'test/sample.dart'),
        ).approvedFileName,
        throwsA(
          isA<InvalidApprovalNameException>().having(
            (e) => e.component,
            'component',
            'test name',
          ),
        ),
      );
    });

    test('omits the test segment when addTestName is false', () {
      BaseNamer.ambientTestName = () => null;

      const namer = Namer(
        filePath: 'test/sample.dart',
        addTestName: false,
        context: ApprovalContext(sourcePath: 'test/sample.dart'),
      );

      expect(namer.approvedFileName, equals('sample.approved.txt'));
    });

    test('keeps standalone naming working without a context', () {
      BaseNamer.ambientTestName = () => null;

      const namer = Namer(filePath: 'test/sample.dart');

      expect(namer.approvedFileName, equals('sample.approved.txt'));
    });
  });

  group('ApprovalContext and IndexedNamer counters |', () {
    setUp(IndexedNamer.resetCounters);

    test('separates counters by source path when filePath is unresolved', () {
      final first = IndexedNamer(
        addTestName: false,
        context: const ApprovalContext(sourcePath: 'a.dart', testName: 'same'),
      );
      final second = IndexedNamer(
        addTestName: false,
        context: const ApprovalContext(sourcePath: 'b.dart', testName: 'same'),
      );

      expect((first.counter, second.counter), equals((0, 0)));
    });

    test('increments for repeated verifications of one context', () {
      const context = ApprovalContext(sourcePath: 'a.dart', testName: 'same');

      expect(IndexedNamer(addTestName: false, context: context).counter, 0);
      expect(IndexedNamer(addTestName: false, context: context).counter, 1);
    });

    test('prefers an explicit filePath over the context source path', () {
      const context = ApprovalContext(sourcePath: 'shared.dart', testName: 't');

      final first = IndexedNamer(
        filePath: 'one.dart',
        addTestName: false,
        context: context,
      );
      final second = IndexedNamer(
        filePath: 'two.dart',
        addTestName: false,
        context: context,
      );

      expect((first.counter, second.counter), equals((0, 0)));
    });

    test('copyWith carries the counter rather than re-allocating it', () {
      const context = ApprovalContext(sourcePath: 'a.dart', testName: 't');
      final namer = IndexedNamer(addTestName: false, context: context);

      expect(namer.copyWith(filePath: 'a.dart').counter, equals(namer.counter));
    });
  });

  group('Approvals with an explicit context |', () {
    test('writes beside the context source instead of the test file', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_verify');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final sourcePath = p.join(tempDir.path, 'generated_report.dart');

      Approvals.verify(
        'report body',
        options: Options(
          namer: Namer(
            filePath: null,
            addTestName: false,
            context: ApprovalContext(sourcePath: sourcePath),
          ),
          logErrors: false,
          logResults: false,
        ),
      );

      expect(
        File(p.join(tempDir.path, 'generated_report.approved.txt'))
            .existsSync(),
        isTrue,
      );
    });

    test('names the colliding verification after the context test name', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_collision');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final sourcePath = p.join(tempDir.path, 'collide.dart');

      const context = ApprovalContext(
        sourcePath: 'collide.dart',
        testName: 'context owned verification',
      );
      final namer = Namer(
        filePath: sourcePath,
        addTestName: false,
        context: context,
      );

      Approvals.verify(
        'first',
        options: Options(namer: namer, logErrors: false, logResults: false),
      );

      expect(
        () => Approvals.verify(
          'second',
          options: Options(namer: namer, logErrors: false, logResults: false),
        ),
        throwsA(
          isA<ApprovalPathCollisionException>().having(
            (e) => e.firstVerification,
            'firstVerification',
            contains('context owned verification'),
          ),
        ),
      );
    });

    test('still supports a namer without the context capability', () {
      final tempDir = Directory.systemTemp.createTempSync('ctx_absent');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final namer = _ContextlessNamer(
        approved: p.join(tempDir.path, 'legacy.approved.txt'),
        received: p.join(tempDir.path, 'legacy.received.txt'),
      );

      Approvals.verify(
        'legacy body',
        options: Options(namer: namer, logErrors: false, logResults: false),
      );

      expect(File(namer.approved).existsSync(), isTrue);
    });
  });
}
