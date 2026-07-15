# Core Dart Package Rules

## Public API

- Confirm whether a symbol is exported through `lib/approval_tests.dart` before changing it.
- Preserve constructor defaults, exception types, and artifact formats in bug fixes.
- Add public behavior to the existing library parts and keep implementation-only helpers under `lib/src/`.
- Use typed package exceptions for validation, mismatch, collision, and missing-file failures.

## Implementation

- Keep models immutable and use `final` fields by default.
- Use sealed classes only when callers benefit from exhaustive handling.
- Prefer SDK APIs and current dependencies before adding a package.
- Keep synchronous public flows synchronous unless the task authorizes an API change.
- Preserve the original exception when cleanup also fails; log cleanup failure separately.
- Avoid logging artifact content, unsafe input values, or machine-specific sensitive paths unnecessarily.

## Tests

- Put shared approval behavior in `test/groups/` and register it through the existing suite pattern.
- Put focused CLI and writer behavior under their matching `test/` directories.
- Create filesystem fixtures below `Directory.systemTemp` and register `addTearDown` immediately.
- Assert externally visible behavior and typed errors rather than private implementation calls.
- Use condition-based coordination for concurrency tests and bound every wait.
- Keep approved fixtures reviewed and committed; keep received fixtures disposable.

## Verification

- Run `dart format --set-exit-if-changed .` after Dart edits.
- Run `dart analyze .` with zero issues.
- Run targeted tests before `dart test`.
- Run randomized test order when shared static or registry state changes.
- Check the matrix-sensitive area against Windows, macOS, and Linux semantics.
