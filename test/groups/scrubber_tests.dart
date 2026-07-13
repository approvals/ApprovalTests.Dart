import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerScrubberTests();

void registerScrubberTests() {
  group('CompositeScrubber', () {
    test('applies scrubbers in declaration order', () {
      final scrubber = CompositeScrubber([
        const _ReplaceScrubber('alpha', 'beta'),
        const _ReplaceScrubber('beta', 'gamma'),
      ]);

      expect(scrubber.scrub('alpha beta'), 'gamma gamma');
    });

    test('returns the input unchanged when no scrubbers are supplied', () {
      final scrubber = CompositeScrubber([]);

      expect(scrubber.scrub('unchanged'), 'unchanged');
    });

    test('is not affected when the supplied list is mutated', () {
      final scrubbers = <ApprovalScrubber>[
        const _ReplaceScrubber('alpha', 'beta'),
      ];
      final scrubber = CompositeScrubber(scrubbers);

      scrubbers.add(const _ReplaceScrubber('beta', 'gamma'));

      expect(scrubber.scrub('alpha'), 'beta');
    });
  });
}

class _ReplaceScrubber implements ApprovalScrubber {
  const _ReplaceScrubber(this.pattern, this.replacement);

  final String pattern;
  final String replacement;

  @override
  String scrub(String input) => input.replaceAll(pattern, replacement);
}
