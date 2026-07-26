## 1.7.0

### Added

- Added `ApprovalContext`, an explicit verification identity carrying the
  source path and test name, plus the `ContextAwareNamer` capability that
  exposes it. Supplying a context replaces stack-trace parsing and
  `package:test` internals for that verification; omitting it keeps the 1.x
  inference, so existing approval names are unchanged byte for byte.
  Constructing an `ApprovalContext` with an empty `sourcePath` is rejected.
  `Namer` and `IndexedNamer` accept and copy a `context`.
- A context that supplies no `testName` while no test framework is active and
  `addTestName` is `true` now fails with `InvalidApprovalNameException` instead
  of silently collapsing every verification in the file onto one artifact name.
- Added `ReporterAvailability`, an explicit contract letting a reporter declare
  whether it can run in the current environment. A `Reporter` that does not
  implement it is treated as always available, so existing custom reporters
  keep working unchanged.
- Added `FirstWorkingReporter`, which reports through the first available entry
  in declaration order. One configuration now covers a local diff tool and a
  headless CI runner. Throws `NoAvailableReporterException` when no entry is
  available.
- Added `MultiReporter`, which reports through every available entry
  sequentially in declaration order. The first failure is rethrown after the
  remaining reporters have run; later failures are logged so none is lost.
- Added `NoAvailableReporterException`, which names the reporters it checked.
- `CommandLineReporter`, `DiffReporter`, and `GitReporter` now declare
  availability. `GitReporter` probes its command with `--version`.

### Changed

- Renamed `DiffReporter.isReporterAvailable` to `DiffReporter.isAvailable` so
  availability has one name across all reporters. The old getter still works
  and is deprecated for removal in 2.0.0.
- `Options.reporter` still defaults to `CommandLineReporter`; reporter
  composition is opt-in.

### Notes

- `ApprovalContext` deliberately carries no `description`. `ApprovalNamer`
  already owns one, used in both the artifact name and the collision
  diagnostic; a second source would need a winner picked in two places.
  Artifact-level descriptions are deferred to the artifact model.
- `package:test_api` remains a dependency. `Invoker` still supplies the ambient
  test name, the collision-registry owner, and the collision diagnostic name.
  `ApprovalContext` makes it unnecessary per verification, not per package;
  removing it is a 2.0 concern.

### Internal

- Maintained 100% executable line coverage (792/792 lines); all 256 test
  executions pass.

## 1.6.1

### Fixed

- Fixed atomic text replacement on Windows when concurrent readers temporarily
  lock the destination. Access, sharing, and lock violations are retried with a
  bounded attempt count while the existing artifact remains intact.

### Internal

- Corrected cross-platform path expectations to use native separators on Windows, macOS, and Linux.
- Added deterministic coverage for successful Windows lock retries, non-retryable failures, and retry exhaustion.
- Added project AgentSync rules for portable path handling and atomic file replacement semantics.

## 1.6.0

### Added

- Added `ScrubWithAliases` for preserving relationships between repeated
  volatile values and `ScrubUuids` for case-insensitive canonical UUID aliases.
- Added typed `InvalidApprovalNameException` and
  `ApprovalPathCollisionException` diagnostics for unsafe names and duplicate
  artifact paths.

### Changed

- Text artifacts are now written through same-directory temporary files and
  atomically replaced, so concurrent readers cannot observe partial content.
- Approval filename segments now normalize platform-invalid characters and
  reserved names consistently. Names longer than 255 UTF-8 bytes keep a
  readable prefix plus a stable hash; existing valid names are unchanged.
- Approved and received paths are validated and claimed as one pair before
  artifact I/O. Duplicate paths fail with both verification identities.

### Fixed

- Failed path-pair validation no longer reserves the valid path, so callers can
  correct an unsafe custom namer and retry without a false collision.

### Internal

- Expanded deterministic regression coverage for safe naming boundaries,
  collision claims, atomic replacement and cleanup failures, alias-preserving
  scrubbers, and the review CLI's console, process, and default-tool wiring.
- Reached 100% line coverage for executable library code (728/728 lines); both
  the full and randomized-order suites pass all 166 test executions.

## 1.5.0

### Added

- Added `CompositeScrubber` for applying multiple scrubbers in a predictable
  order.
- Added `MissingApprovedPolicy` with backwards-compatible `createAndPass` and
  strict `writeReceivedAndFail` modes. Strict failures expose
  `ApprovalMismatchKind.missingApproved` and leave the received artifact for
  review without writing the approved file.

### Changed

- Replaced `talker` with the pure-Dart `ispectify 6.1.2` logging core. Console
  diagnostics now preserve exception stack traces without retaining in-memory
  log history.
- Raised the minimum supported Dart SDK to 3.6 for `ispectify 6.1.2`.

### Fixed

- Fixed the review CLI to process prompts sequentially, validate received
  artifact paths, sort discovered files deterministically, and await diff
  reporter failures.

## 1.4.3

- Clearer failure messages: file paths now shown in `DoesntMatchException` and `CommandLineReporter`.
- Platform-agnostic path handling.
- Release notes now include CHANGELOG content.
- Minor performance optimizations and new test coverage.

## 1.4.2

- Added `convertObject()` to `ApprovalConverter` for direct object-to-JSON conversion.
- Added `resetCounters()` to `IndexedNamer`.
- Fixed double logging of `DoesntMatchException` in `Approvals.verify`.
- Guarded unawaited reporter call with `.catchError` to prevent unhandled async exceptions.
- Internal refactoring: extracted shared utilities, cached `RegExp` instances, simplified code paths.

## 1.4.1

- Fixed `ScrubDates` to implement `ApprovalScrubber` directly.
- Fixed dead code in `CommandLineReporter` buffer tracking.
- Fixed typo in filename: `comporator_ide.dart` → `comparator_ide.dart`.
- Internal refactoring: deduplicated shared logic in namer, reporters, and utilities.

## 1.4.0

### Testing

- Ensured `test/approval_test.dart` invokes every suite under `test/groups`, so the aggregated run covers all group-level tests.
- Restored synchronous verification helpers and reporter interfaces to maintain backwards compatibility for 1.x consumers.

## 1.3.6

### Improvements

- Normalized JSON conversion to produce valid output for any map keys and optional class wrappers.
- Preserved whitespace during comparisons by updating `ApprovalUtils.readFile` and `FileComparator`.
- Ensured received files delete even when result logging is disabled.
- Reset `ScrubDates` counters per invocation and removed double separators from namer outputs.
- Hardened diff tooling by validating Git/diff arguments, improving reporting.
- Documented the deterministic query workflow and reporter argument handling in `README.md`.

### Testing

- Added regression coverage for whitespace comparisons, date scrubbing, converter encoding, and options copy semantics.
- Introduced deterministic stubs for network query tests and refreshed related approvals.
- Added reporter regression tests covering Git/Diff custom command execution and argument expansion.

## 1.2.1

### Indexed Namer

- Added the `IndexedNamer`. This class allows you to create a Namer that includes an index in the file name. It is useful when you need to multiple verify calls in a single test.
  - Please see the [Indexed Namer Example](example/auto_namer.dart)

### URL Updates

- Updated URLs in LICENSE to use HTTPS.
- Updated the license badge URL in README.md to use HTTPS.

### Code Refactoring

- Removed the `makeNamer` factory method in `lib/src/approvals.dart` and replaced it with `copyWith` for creating Namer instances.
- Added a `_normalizeContent` method in `lib/src/comparator/file_comparator.dart` to standardize line endings and trim whitespace for file comparisons.

### Documentation Adjustments

- Removed the Pub popularity badge from README.md.

### Other Changes

- Added the `--generate-notes` option to the `gh release create` command in `.github/workflows/publish.yml`.
- Updated `example/main.dart` to use a Namer with a subfolder and a CommandLineReporter in `verifyAll`.

## 1.1.6

- Upgraded all dependencies to actuals.

## 1.1.3

- Updated README.md file: fix links.

## 1.1.2

- Added CLI additional options:  
   Usage: `dart run approval_tests:review [arguments]`
  - Arguments:
    - `--help` Print this usage information.
    - `--list` Print a list of project .received.txt files.
    - `<index>` Review an .received.txt file indexed by --list.
    - `<path/to/.received.txt>` Review an .received.txt file.

## 1.1.1

- Updated README.md file.

## 1.1.0

- **Breaking release**:
  - Added new reporter: `GitReporter`. It allows you to use `git` to view the differences between the received and approved files.
  - Added support to approve files using CLI. Now you can approve files using the command line: `dart run approval_tests:review`
  - Added support to use ApprovalTests during widget tests.
  - Added header to generated files. For resolved issues you can add this to approved files:  
    '# This file was generated by approval_tests. Please do not edit.\n'
  - Some minor changes and code improvements.
    Thanks to [Richard Coutts](https://github.com/buttonsrtoys)

## 1.0.0

- Initial major release.

## 0.5.1

- Updated documentation.
- Updated dependencies.
- Updated `README.md` file.
- Updated `TODO.md` file.
- Rewrited comparators. Now it is only FileComparator.
- Rewrited Scrubbers: regex scrubber, date scrubber.
- Now, first run automatically create approved snapshot. You can approve another snapshot by setting `approveResult` to `true` and using Diff Tool.
- Completely rewritten `CommandLineReporter`.
  There were changes with the comparison method, as well as highlighting by color the places where there are differences. Green - approved. White text on red background - Differences in received file.
- Internal updates such as:
  - Adding android studio installation via github actions to test Diff Reporter on different devices.
  - Full code test coverage after significant changes.
  - Changes to getting file name and path depending on platform.

## 0.4.6

- Updated dependencies. Removed `dcli` package.
- Issue https://github.com/approvals/ApprovalTests.Dart/issues/3 was fixed.
- Minor changes: `IDEComparator` now gets the current `StackTrace` if an error occurs.

## 0.4.5

- Updated dependencies and actions versions.
- Updated Logger's output: now it is more informative.
- Updated `CONTRIBUTING.md` file: added Arlo's Commit Notation.

## 0.4.4

- Added setup visual studio code action to the `build_and_test` workflow for test `IDEComparator`.

## 0.4.3

- Completed coverage of the project with tests. Now the project has 100% coverage.

## 0.4.2

- Autopublish to `pub.dev` if the version in `pubspec.yaml` has been changed by auto adding a new tag to the repositories.
- Codecov added to `github` actions. Codecov badge, graph was added to `README.md`.
- Added `mdsnippets` to `github` actions. And example snippets added to `README.md`.
- Added `ApprovalTests.Dart.StarterProject`. You can find it in the `README.md` file.

## 0.3.9

- Fix with default file path if package from `pub.dev`.
- Gilded rose moved to starter project.
- Code formatted.

## 0.3.8

- Test publish action with new version: `v0.3.8`.

## 0.3.6-dev

- Updated `pubspec.yaml` file: changed homepage.

## 0.3.5-dev

- The repository has been moved to Approvals.
- Fixed bug with checking of strings received from `txt` file.
- Added `Github` Actions.
- Added `dependabot`.
- Updated `README.md` file.
- Updated `TODO.md` file.

## 0.3.3-dev

- Updated `README.md` file.

## 0.3.2-dev

- Default `lints` replaced by `sizzle_lints`.
- Updated `analysis_options` file.
- Updated `README.md` file.

## 0.3.1-dev

- Updated `README.md` file.

## 0.3.0-dev

- Approval was refactored.
- Added tests.
- Code formatted.
- `deleteReceivedFile` field was added to the `ApprovalTests` class. If it is set to `true`, the received file will be deleted after test. By default, it is set to `false`.
- `logErrors` field was added to the `ApprovalTests` class. If it is set to `true`, the errors will be logged. By default, it is set to `true`.
- `logResults` field was added to the `ApprovalTests` class. If it is set to `true`, the success results will be logged. By default, it is set to `true`.

## 0.2.1-dev

- Fix: `approval_dart` changed to `approval_tests`.
- Code formatted.

## 0.2.0-dev

- I rewrote the main functions of the class. Now you can use several comparison options.
- Added methods for comparing `JSON` strings.
- Added methods for array comparison.
- Improved documentation.
- Added more examples: each method has its own small example.

## 0.1.0-dev

- Added `verifyAll` method to verify array of items _(or use array as inputs)_.
- Added `verifyAllCombinationsAsJson` method to verify all combinations of items as `JSON`.
- Updated `README.md` file.

## 0.0.9-dev

- Updated `README.md` file.

## 0.0.8-dev

- Updated `README.md` file: added examples, more info.

## 0.0.7-dev

- Comparator completed, some refactoring. Updated `README.md` file.

## 0.0.6-dev

- Some updates with `README.md` file.

## 0.0.5-dev

- First working version, need to expand functionality and add more flexibilty. Also need to add more tests.

## 0.0.1-dev

- Initial version.
