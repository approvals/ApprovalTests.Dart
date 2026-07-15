import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerScrubberTests();

void registerScrubberTests() {
  group('ScrubWithAliases', () {
    test('reuses aliases and numbers distinct values by first appearance', () {
      const scrubber = ScrubWithAliases(
        pattern: r'user-\d+',
        alias: 'user',
      );

      expect(
        scrubber.scrub('owner=user-42 member=user-42 reviewer=user-7'),
        'owner=<user1> member=<user1> reviewer=<user2>',
      );
    });

    test('resets aliases for every scrub operation', () {
      const scrubber = ScrubWithAliases(
        pattern: r'id-\d+',
        alias: 'id',
      );

      expect(scrubber.scrub('id-8 id-9'), '<id1> <id2>');
      expect(scrubber.scrub('id-9'), '<id1>');
    });

    test('preserves input exactly when the pattern does not match', () {
      const scrubber = ScrubWithAliases(
        pattern: r'id-\d+',
        alias: 'id',
      );

      expect(scrubber.scrub('  unchanged\n'), '  unchanged\n');
      expect(scrubber.scrub(''), '');
    });

    test('treats case variants as one value when case is ignored', () {
      const scrubber = ScrubWithAliases(
        pattern: r'user-[a-z]+',
        alias: 'user',
        caseSensitive: false,
      );

      expect(
        scrubber.scrub('USER-ALPHA user-alpha User-Beta'),
        '<user1> <user1> <user2>',
      );
    });

    test('matches case-sensitively by default', () {
      const scrubber = ScrubWithAliases(
        pattern: r'user-[a-z]+',
        alias: 'user',
      );

      expect(scrubber.scrub('USER-ALPHA user-alpha'), 'USER-ALPHA <user1>');
    });

    test('keeps prefix-overlapping values distinct', () {
      const scrubber = ScrubWithAliases(
        pattern: r'item-\d+',
        alias: 'item',
      );

      expect(
        scrubber.scrub('item-1 item-10 item-1'),
        '<item1> <item2> <item1>',
      );
    });

    test('surfaces malformed regular expressions', () {
      const scrubber = ScrubWithAliases(pattern: '[');

      expect(() => scrubber.scrub('value'), throwsFormatException);
    });
  });

  group('ScrubUuids', () {
    test('aliases canonical UUIDs case-insensitively', () {
      const scrubber = ScrubUuids();

      expect(
        scrubber.scrub(
          'request=550e8400-e29b-41d4-a716-446655440000 '
          'owner=550E8400-E29B-41D4-A716-446655440000 '
          'trace=123e4567-e89b-12d3-a456-426614174000',
        ),
        'request=<uuid1> owner=<uuid1> trace=<uuid2>',
      );
    });

    test('does not scrub a UUID-shaped substring inside a larger identifier',
        () {
      const scrubber = ScrubUuids();
      const embedded = 'x550e8400-e29b-41d4-a716-446655440000y';

      expect(scrubber.scrub(embedded), embedded);
    });

    test('resets UUID aliases for every scrub operation', () {
      const scrubber = ScrubUuids();

      expect(
        scrubber.scrub('550e8400-e29b-41d4-a716-446655440000'),
        '<uuid1>',
      );
      expect(
        scrubber.scrub('123e4567-e89b-12d3-a456-426614174000'),
        '<uuid1>',
      );
    });
  });

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
