import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() => registerReporterCompositionTests();

/// Reporter without the [ReporterAvailability] contract.
final class _PlainReporter implements Reporter {
  var callCount = 0;

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    callCount++;
  }
}

/// Reporter with a fixed availability answer that records invocation order.
final class _FakeReporter implements ReporterAvailability {
  _FakeReporter({
    required this.name,
    required this.isAvailable,
    this.order,
    this.failure,
  });

  final String name;
  final List<String>? order;
  final Object? failure;
  var callCount = 0;

  @override
  final bool isAvailable;

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    callCount++;
    order?.add(name);
    if (failure case final error?) {
      throw error;
    }
  }
}

void registerReporterCompositionTests() {
  group('ReporterAvailability contract |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Reporter composition tests are starting $lines25",
      );
    });

    test('treats a reporter without the contract as available', () {
      expect(ReporterAvailability.of(_PlainReporter()), isTrue);
    });

    test('honours an implementing reporter in both directions', () {
      expect(
        ReporterAvailability.of(
          _FakeReporter(name: 'yes', isAvailable: true),
        ),
        isTrue,
      );
      expect(
        ReporterAvailability.of(
          _FakeReporter(name: 'no', isAvailable: false),
        ),
        isFalse,
      );
    });

    test('CommandLineReporter is always available', () {
      expect(const CommandLineReporter().isAvailable, isTrue);
    });

    test('DiffReporter is unavailable on an unsupported platform', () {
      const reporter = DiffReporter(platformWrapper: NoPlatformWrapper());

      expect(reporter.isAvailable, isFalse);
    });

    test('DiffReporter reports availability of a custom command file', () {
      final tempDir = Directory.systemTemp.createTempSync('diff_availability');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final existing = File('${tempDir.path}/diff_tool')
        ..writeAsStringSync('#!/bin/sh\n');

      final available = DiffReporter(
        customDiffInfo: DiffInfo(name: 'c', command: existing.path, arg: ''),
      );
      final missing = DiffReporter(
        customDiffInfo: DiffInfo(
          name: 'c',
          command: '${tempDir.path}/absent',
          arg: '',
        ),
      );

      expect(available.isAvailable, isTrue);
      expect(missing.isAvailable, isFalse);
    });

    test('deprecated isReporterAvailable delegates to isAvailable', () {
      const reporter = DiffReporter(platformWrapper: NoPlatformWrapper());

      // ignore: deprecated_member_use_from_same_package
      expect(reporter.isReporterAvailable, equals(reporter.isAvailable));
    });

    test('GitReporter is available when git answers --version', () {
      final reporter = GitReporter(
        runProcessSync: (command, arguments) =>
            ProcessResult(0, 0, 'git version 2.0.0', ''),
      );

      expect(reporter.isAvailable, isTrue);
    });

    test('GitReporter is unavailable on a non-zero exit code', () {
      final reporter = GitReporter(
        runProcessSync: (command, arguments) => ProcessResult(0, 127, '', ''),
      );

      expect(reporter.isAvailable, isFalse);
    });

    test('GitReporter is unavailable when the executable is missing', () {
      final reporter = GitReporter(
        runProcessSync: (command, arguments) =>
            throw ProcessException(command, arguments, 'not found', 2),
      );

      expect(reporter.isAvailable, isFalse);
    });

    test('GitReporter probes the custom command', () {
      final probed = <String>[];
      final reporter = GitReporter(
        customDiffInfo: const DiffInfo(name: 'c', command: 'hub', arg: ''),
        runProcessSync: (command, arguments) {
          probed.add(command);
          return ProcessResult(0, 0, '', '');
        },
      );

      expect(reporter.isAvailable, isTrue);
      expect(probed.single, equals('hub'));
    });
  });

  group('FirstWorkingReporter |', () {
    test('skips unavailable reporters and uses the first available one', () {
      final unavailable = _FakeReporter(name: 'a', isAvailable: false);
      final available = _FakeReporter(name: 'b', isAvailable: true);
      final later = _FakeReporter(name: 'c', isAvailable: true);

      final composite = FirstWorkingReporter([unavailable, available, later]);

      expect(
        composite.report('approved.txt', 'received.txt'),
        completes,
      );
      expect(unavailable.callCount, isZero);
      expect(later.callCount, isZero);
    });

    test('selects in declaration order', () async {
      final first = _FakeReporter(name: 'first', isAvailable: true);
      final second = _FakeReporter(name: 'second', isAvailable: true);

      await FirstWorkingReporter([first, second]).report('a', 'b');
      expect((first.callCount, second.callCount), equals((1, 0)));

      await FirstWorkingReporter([second, first]).report('a', 'b');
      expect((first.callCount, second.callCount), equals((1, 1)));
    });

    test('propagates a failure from the selected reporter', () async {
      final failing = _FakeReporter(
        name: 'failing',
        isAvailable: true,
        failure: StateError('diff tool crashed'),
      );
      final fallback = _FakeReporter(name: 'fallback', isAvailable: true);

      await expectLater(
        FirstWorkingReporter([failing, fallback]).report('a', 'b'),
        throwsA(isA<StateError>()),
      );
      expect(fallback.callCount, isZero);
    });

    test('throws when every reporter is unavailable', () async {
      final composite = FirstWorkingReporter([
        _FakeReporter(name: 'a', isAvailable: false),
        _FakeReporter(name: 'b', isAvailable: false),
      ]);

      await expectLater(
        composite.report('a', 'b'),
        throwsA(isA<NoAvailableReporterException>()),
      );
    });

    test('throws when no reporter is configured', () async {
      await expectLater(
        const FirstWorkingReporter([]).report('a', 'b'),
        throwsA(isA<NoAvailableReporterException>()),
      );
    });

    test('is available when at least one entry is available', () {
      expect(
        FirstWorkingReporter([
          _FakeReporter(name: 'a', isAvailable: false),
          _FakeReporter(name: 'b', isAvailable: true),
        ]).isAvailable,
        isTrue,
      );
      expect(
        FirstWorkingReporter([
          _FakeReporter(name: 'a', isAvailable: false),
        ]).isAvailable,
        isFalse,
      );
    });

    test('an unusable chain does not mask the mismatch in verify', () async {
      final tempDir = Directory.systemTemp.createTempSync('unusable_chain');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      File('${tempDir.path}/source.approved.txt').writeAsStringSync(
        '${ApprovalTestsConstants.baseHeader}expected',
      );

      expect(
        () => Approvals.verify(
          'actual',
          options: Options(
            namer: Namer(
              filePath: '${tempDir.path}/source.dart',
              addTestName: false,
            ),
            reporter: FirstWorkingReporter([
              _FakeReporter(name: 'unavailable', isAvailable: false),
            ]),
            logErrors: false,
            logResults: false,
          ),
        ),
        throwsA(isA<DoesntMatchException>()),
      );
    });

    test('falls back to the command line on a headless host', () async {
      final tempDir = Directory.systemTemp.createTempSync('headless_fallback');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/a.approved.txt')
        ..writeAsStringSync('expected');
      final received = File('${tempDir.path}/a.received.txt')
        ..writeAsStringSync('actual');

      const composite = FirstWorkingReporter([
        DiffReporter(platformWrapper: NoPlatformWrapper()),
        CommandLineReporter(),
      ]);

      await expectLater(
        composite.report(approved.path, received.path),
        completes,
      );
    });
  });

  group('MultiReporter |', () {
    test('invokes every available reporter in configuration order', () async {
      final order = <String>[];
      final composite = MultiReporter([
        _FakeReporter(name: 'first', isAvailable: true, order: order),
        _FakeReporter(name: 'second', isAvailable: true, order: order),
        _FakeReporter(name: 'third', isAvailable: true, order: order),
      ]);

      await composite.report('a', 'b');

      expect(order, equals(['first', 'second', 'third']));
    });

    test('skips unavailable reporters', () async {
      final skipped = _FakeReporter(name: 'skipped', isAvailable: false);
      final used = _FakeReporter(name: 'used', isAvailable: true);

      await MultiReporter([skipped, used]).report('a', 'b');

      expect((skipped.callCount, used.callCount), equals((0, 1)));
    });

    test('rethrows the first failure after running the rest', () async {
      final logged = <Object>[];
      final failing = _FakeReporter(
        name: 'failing',
        isAvailable: true,
        failure: StateError('first'),
      );
      final later = _FakeReporter(name: 'later', isAvailable: true);

      await expectLater(
        MultiReporter(
          [failing, later],
          exceptionLogger: (e, {stackTrace}) => logged.add(e),
        ).report('a', 'b'),
        throwsA(isA<StateError>()),
      );
      expect(later.callCount, equals(1));
      expect(logged, isEmpty);
    });

    test('logs later failures without masking the first', () async {
      final logged = <Object>[];
      final composite = MultiReporter(
        [
          _FakeReporter(
            name: 'a',
            isAvailable: true,
            failure: StateError('first'),
          ),
          _FakeReporter(
            name: 'b',
            isAvailable: true,
            failure: ArgumentError('second'),
          ),
        ],
        exceptionLogger: (e, {stackTrace}) => logged.add(e),
      );

      await expectLater(
        composite.report('a', 'b'),
        throwsA(isA<StateError>()),
      );
      expect(logged.single, isA<ArgumentError>());
    });

    test('completes when nothing is available', () async {
      await expectLater(const MultiReporter([]).report('a', 'b'), completes);
      await expectLater(
        MultiReporter([_FakeReporter(name: 'a', isAvailable: false)])
            .report('a', 'b'),
        completes,
      );
    });

    test('is available when at least one entry is available', () {
      expect(
        MultiReporter([
          _FakeReporter(name: 'a', isAvailable: false),
          _FakeReporter(name: 'b', isAvailable: true),
        ]).isAvailable,
        isTrue,
      );
      expect(
        MultiReporter([_FakeReporter(name: 'a', isAvailable: false)])
            .isAvailable,
        isFalse,
      );
    });
  });

  group('NoAvailableReporterException |', () {
    test('names the reporters that were checked', () {
      final exception = NoAvailableReporterException(
        reporters: [const CommandLineReporter(), const DiffReporter()],
      );

      expect(
        exception.toString(),
        allOf(
          contains('CommandLineReporter'),
          contains('DiffReporter'),
          contains('headless CI'),
        ),
      );
    });

    test('explains an empty configuration', () {
      const exception = NoAvailableReporterException(reporters: []);

      expect(exception.toString(), contains('none were configured'));
    });
  });
}
