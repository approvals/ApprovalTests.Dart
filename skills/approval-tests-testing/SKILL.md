---
name: approval-tests-testing
description: "Use when writing or reviewing approval_tests text or JSON snapshots, naming artifacts, or reviewing received files."
---

# Dart approval tests

Use `package:approval_tests/approval_tests.dart` from tests. Add
`approval_tests` and `test` to the consumer's `dev_dependencies`. Check the
resolved package version before using an API: this skill describes 1.7.2.
For rendered Flutter UI, use `approval_tests_flutter` and its widget-testing
skill instead.

## Choose the snapshot boundary

- Use `Approvals.verify(String)` for readable text and
  `Approvals.verifyAsJson(value)` for JSON-compatible maps or lists. For a
  model with `toJson()`, pass its result explicitly.
- Use `verifySequence(List)` for each element's `toString()` on its own line,
  or `verifyAll(inputs, processor: ...)` for an explicit text representation.
- Keep focused assertions for individual values and business rules. Snapshot
  a stable, reviewable result rather than an entire unrelated object graph.
- Stabilize fixtures, clocks, collection order, and locale before capture.
  Use an `Options.scrubber` only for intentionally volatile values. Preserve
  meaningful differences; `ScrubUuids` preserves repeated UUID relationships
  through aliases, and `CompositeScrubber` applies scrubbers in order.
- Verification is synchronous except for `verifyQuery`, which must be awaited.
  Use deterministic query fakes rather than live services in tests.

## Start a test

```dart
import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('renders an invoice', () {
    Approvals.verifyAsJson(
      {
        'customer': 'Ada',
        'items': ['Notebook', 'Pencil'],
        'total': 12,
      },
    );
  });
}
```

Run `dart test`. With default `Options`, the first run creates a missing
approved file and passes; inspect that file before committing it. A mismatch
throws `DoesntMatchException` and leaves the received text for review. A
successful match removes the received file by default.

## Name independent approvals

Default names infer the source file and current test name. When a test makes
multiple verifications, give each `Namer` a distinct `description` or use
`IndexedNamer`. Do not reuse one artifact path for different checks.

For a custom runner or shared test harness, pass `ApprovalContext` to the
namer, not to `Options`. This explicit example also gives the check a unique
description:

```dart
import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('renders a paid invoice', () {
    Approvals.verify(
      'Paid: 12',
      options: Options(
        namer: Namer(
          context: ApprovalContext(
            sourcePath: 'test/invoice_test.dart',
            testName: 'renders a paid invoice',
          ),
          description: 'summary',
        ),
        missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
      ),
    );
  });
}
```

Adapt `sourcePath` to the real test file. Omitted context fields retain
inference. Keep directory paths in path parameters: test names, descriptions,
and file-name segments cannot contain `/` or `\`: these separators throw
`InvalidApprovalNameException`. Other platform-invalid characters, reserved
names, and trailing dots or spaces are normalized. Colliding normalized paths throw
`ApprovalPathCollisionException`. Fix the identity rather than swallowing
either failure.

## Review and protect baselines

1. Run `dart run approval_tests:review --list` to list received text files.
2. Inspect the approved/received diff. Run `dart run approval_tests:review`
   or pass a listed index or received path; choose `v` to view, `y` to approve,
   or `n` to reject. Approve only an intentional, reviewed change within the
   user's request; a failing test alone is not permission to update baselines.
3. Rerun the affected test, then commit reviewed `*.approved.*` artifacts.
   Ignore `*.received.*` and `**/.approval_tests/` in the consumer's Git config.

For CI, set
`Options(missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail)`.
Strict mode leaves a received file and fails on a missing baseline without
writing approved artifacts, even if `approveResult` is true. Keep
`approveResult: true` limited to an explicitly requested local migration and
remove it afterwards. Never use automatic approval to hide a regression.

`CommandLineReporter` is the default. For local IDE diffs with a console
fallback, use
`FirstWorkingReporter([DiffReporter(), CommandLineReporter()])` in `Options`.
Reporter availability is separate from a successful launch; surface tool
failures rather than treating them as approval.
