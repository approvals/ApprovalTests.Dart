# ApprovalTests.Dart Roadmap

Last updated: 2026-07-15

Current baseline:

- latest published package:
  [`approval_tests 1.5.0`](https://pub.dev/packages/approval_tests);
- repository baseline: `main` at `4e3fd3e`, with the 1.6.0 delivery slices
  completed in the current working tree;
- current development version: `1.6.0`;
- version 1.5.0 includes `CompositeScrubber`, the sequential and validated
  review CLI, the `ispectify` logging migration, explicit missing-approved
  policy, and the Dart 3.6 minimum;
- version 1.6.0 adds atomic text writes, safe naming, deterministic length
  limits, typed collision diagnostics, alias-preserving scrubbers, and 100%
  line coverage for executable library code;
- version 1.5.0 requires Dart 3.6 because `ispectify 6.1.2` is the internal
  console logging backend;
- compatibility policy: existing `verify()` calls and `.approved.txt` files
  remain valid throughout 1.x.

This roadmap describes the intended direction of `approval_tests`. It is a
priority guide, not a promise of dates or exact public signatures. Every public
API must be validated against real use cases and may be adjusted during design.

The Flutter-specific roadmap lives in
[ApprovalTests.Dart.Flutter](https://github.com/approvals/ApprovalTests.Dart.Flutter).

## Vision

Make approval testing in Dart predictable for text, structured data, generated
files, command-line applications, and multi-step behavior while keeping the
smallest useful core API.

The package should provide:

- deterministic approved artifacts that are easy to review;
- explicit composition points for writers, comparators, scrubbers, namers, and
  reporters;
- an asynchronous artifact pipeline that awaits I/O, cleanup, and reporting;
- safe local and CI review workflows;
- backwards-compatible evolution for existing `.approved.txt` suites;
- no mandatory dependencies for formats a project does not use.

## Guiding principles

1. **Approved output is a public contract.** File naming and serialized output
   do not change silently.
2. **Determinism before convenience.** Volatile data must be normalized
   explicitly rather than ignored broadly.
3. **Additive 1.x evolution.** Existing `verify()` calls and `.approved.txt`
   files keep working. Breaking naming or artifact changes require a major
   release and a migration guide.
4. **Composition over specialized wrappers.** New `verifyFoo()` methods must
   add meaningful formatting, execution, or artifact behavior.
5. **Safe process execution.** Executables and arguments are passed separately;
   shell interpolation is not the default.
6. **CI never approves implicitly.** Automation may collect received files and
   metadata, but approval remains an explicit review action.
7. **One logical verification may own several files.** Related artifacts are
   named, compared, cleaned up, and reported together.
8. **Failures are data before they are text.** CLI, IDE, and CI output is
   rendered from typed results rather than parsed from exception messages.

## Priority model

- **P0 — Correctness and safety:** behavior that can approve the wrong output,
  corrupt an artifact, race, hang, or hide a failure.
- **P1 — Architectural foundation:** capabilities required by several later
  features.
- **P2 — Product capability:** user-facing approval modes built on stable P1
  foundations.
- **Experimental:** useful prior art that needs evidence from real Dart users
  before entering the supported API.

## Current foundation

- [x] Verify strings with approved and received text files.
- [x] Verify JSON, sequences, executable queries, collections, and Cartesian
  combinations.
- [x] Immutable `Options` with configurable namer, comparator, reporter, and
  scrubber.
- [x] Command-line, Git, and IDE diff reporters.
- [x] Interactive review CLI with listing, indexed selection, and path-based
  review.
- [x] Sequential review prompts, deterministic discovery, strict
      `.received.txt` validation, and awaited diff-tool failures.
- [x] Custom regular-expression and date scrubbers.
- [x] `CompositeScrubber` for applying multiple scrubbers in declaration order.
- [x] Alias-preserving regular-expression and UUID scrubbers.
- [x] `ispectify`-based console diagnostics with preserved exception stacks and
      disabled in-memory history.
- [x] Indexed and descriptive approval naming.
- [x] Cross-platform path handling and deterministic regression tests.
- [x] Explicit missing-approved policy with strict verification support.
- [x] Atomic text-artifact replacement under concurrent writes.
- [x] Safe filename segments, deterministic length limits, and collision
      diagnostics.
- [x] 100% line coverage across executable library code, including failure,
      cleanup, process, and default CLI wiring paths.

## Milestone 0 — Safe 1.x maintenance

This milestone addresses current behavior before expanding the public API.
Changes that would alter existing approval results must be introduced as
opt-in behavior in 1.x and may become defaults only in a documented major
release.

### Missing-approved policy — P0

The current implementation creates an approved file and passes when no
approved file exists. Preserve that behavior for compatibility, but make the
policy explicit.

- [x] Add an immutable missing-approved policy with at least compatibility
  (`createAndPass`) and strict (`writeReceivedAndFail`) modes.
- [x] Make strict mode produce a typed `missingApproved` mismatch and leave a
  reviewable received artifact.
- [x] Ensure strict mode never writes or mutates an approved file.
- [x] Document that `approveResult` is a local migration tool and must not be
  enabled in normal CI.
- [ ] Decide the 2.0 default only after publishing migration guidance and
  collecting 1.x usage feedback.

Acceptance criteria:

- existing tests retain current first-run behavior without configuration;
- strict mode fails deterministically on all supported platforms;
- concurrent missing approvals cannot partially overwrite one another;
- README examples distinguish generation, verification, and approval.

### Naming safety and collision detection — P0

Status: complete for the 1.6.0 development tree.

- [x] Validate test names, descriptions, extensions, and converter-produced
  artifact names as filename segments rather than accepting path separators.
- [x] Normalize reserved names, control characters, trailing dots/spaces, and
  platform-specific invalid characters consistently.
- [x] Detect two logical approvals targeting the same output path in one test
  run and fail with both verification identities.
- [x] Define deterministic length limits with a readable prefix plus stable
  hash when a generated name is too long.
- [x] Keep existing valid names byte-for-byte compatible.

Acceptance criteria:

- [x] Unsafe separators fail with `InvalidApprovalNameException` before I/O.
- [x] Invalid characters and reserved names normalize consistently while valid
      names retain their existing bytes.
- [x] Names over 255 UTF-8 bytes retain a readable prefix and stable hash.
- [x] Collisions report both verification identities before writing.
- [x] Approved and received paths are claimed atomically; a rejected pair
      claims neither path.

### Review CLI correctness — P0

Status: complete for the current text-artifact model. Generalizing received
extensions remains intentionally deferred until Milestone 2 provides the
artifact model.

- [x] Review multiple received files sequentially; never run concurrent stdin
  prompts through `Future.wait`.
- [x] Await diff reporters opened from the review flow and surface failures.
- [x] Validate that an input is a supported received artifact before deriving
  or replacing its approved path.
- [x] Sort discovered files by normalized relative path.
- [x] Cover console I/O, default Git and diff-tool wiring, and process failures
  without launching GUI tools.
- [ ] Replace hard-coded `.received.txt` assumptions with the artifact model
  once Milestone 2 lands.
- [x] Correct command hints to use `dart run approval_tests:review`.

### Documentation and release alignment — P0

- [x] Correct examples that pass arbitrary objects to the string-only
  `verify()` API; use `verifyAsJson()` or an explicit formatter.
- [x] Document the completed `CompositeScrubber` change for version 1.5.0 with
      API docs and a migration-neutral example.
- [x] Keep the published 1.5.0 history separate from new development changes.
- [x] Keep the README installation snippet, `pubspec.yaml`, and CHANGELOG
      development heading aligned at version 1.6.0.
- [x] Record the 100% line-coverage gate and its reproducible local command.
- [ ] Publish matching 1.6.0 package, tag, and release notes.
- [x] Document exactly which files belong in source control:
  `*.approved.*` tracked and `*.received.*` ignored.
- [x] Document the Dart 3.6 minimum introduced by the `ispectify` migration in
      README and CHANGELOG.

## Milestone 1 — Deterministic text approvals

This milestone fills the highest-value gaps without changing the artifact
model.

### Exception approvals

- [ ] Add `Approvals.verifyException()` for code expected to throw.
- [ ] Produce stable default output containing the exception type and message.
- [ ] Exclude stack traces by default because paths, SDK frames, and line
  numbers are volatile.
- [ ] Define deterministic output when no exception is thrown.
- [ ] Support existing `Options`, including scrubbers, naming, and reporters.
- [ ] Decide explicitly whether the first API supports synchronous callbacks,
  `FutureOr`, or separate sync/async entry points.

Acceptance criteria:

- synchronous and asynchronous behavior, if supported, has dedicated tests;
- custom exceptions and the no-exception case are covered;
- existing verification behavior and approved files are unchanged.

### Alias-preserving scrubbers

- [x] Add an aliasing regular-expression scrubber.
- [x] Add an opt-in UUID scrubber built on aliasing.
- [ ] Expand date/time support to common ISO-8601 forms without changing the
  existing `ScrubDates` contract silently.
- [ ] Add opt-in normalization for workspace, home-directory, temporary, and
  platform path separators while preserving meaningful relative paths.
- [ ] Consider narrowly scoped URI-port and memory-address scrubbers when real
  examples justify them.

Aliasing must preserve relationships in the snapshot:

```text
userId: <uuid1>
ownerId: <uuid1>
requestId: <uuid2>
```

Acceptance criteria:

- [x] Repeated source values receive the same alias within one scrub operation.
- [x] Counters reset between scrub operations.
- [x] Prefix-overlapping values and mixed-case UUIDs are tested.
- [x] No general-purpose number scrubber is introduced.

### Reporter composition

- [ ] Add a first-working reporter that selects the first available reporter.
- [ ] Add a multi-reporter that invokes every configured reporter.
- [ ] Move reporter availability into an explicit shared contract rather than
  relying on `DiffReporter`-specific knowledge.
- [ ] Distinguish “not available” from “available but failed”; fallback must not
  hide an actual reporter execution error.

Acceptance criteria:

- selection order is deterministic;
- reporter errors remain observable;
- a command-line fallback works on headless CI;
- all composition behavior is covered without launching real GUI tools.

### Explicit verification context

- [ ] Introduce an immutable `ApprovalContext` carrying the source path, test
  name, and optional artifact description.
- [ ] Let test-framework adapters provide context explicitly instead of making
  stack-trace parsing and `test_api` internals mandatory.
- [ ] Keep the current stack-trace-based discovery as a compatibility fallback
  during 1.x.
- [ ] Preserve existing approval names when explicit and inferred context
  describe the same test.

Acceptance criteria:

- custom test runners can provide naming context without fabricated stacks;
- optimized or transformed stack traces are not required by the primary API;
- missing or ambiguous context produces an actionable error;
- removing the compatibility fallback is reserved for a major release.

## Milestone 2 — Artifact-aware verification

This is the main architectural milestone. It should unlock new formats without
growing a separate verification pipeline for each one.

### Awaited verification pipeline

- [ ] Add an asynchronous verification entry point that awaits file writes,
  comparisons, reporter execution, and cleanup.
- [ ] Never use fire-and-forget reporter calls in the asynchronous pipeline.
- [ ] Aggregate verification and reporter failures without losing the original
  mismatch.
- [ ] Keep existing synchronous `verify()` source compatible in 1.x and define
  a measured migration path before considering an async-only major release.
- [ ] Benchmark small text approvals and large artifact bundles before making
  performance claims.

### Multi-artifact verification

- [ ] Define an immutable artifact bundle representing one logical approval
  with one or more named text or binary artifacts.
- [ ] Verify the complete bundle as one logical operation while keeping every
  artifact independently reviewable.
- [ ] Aggregate missing, changed, and unexpected artifacts instead of failing
  on the first mismatch.
- [ ] Detect artifacts left behind when a converter now produces fewer outputs.
- [ ] Support an optional structured metadata artifact alongside generated
  files.

Example use cases include a PDF producing metadata plus one PNG per page, a
web capture producing normalized HTML plus an image, and a Flutter scenario
producing widget metadata, semantics, and a golden image.

### Converter extension point

- [ ] Define an `ApprovalConverter<T>`-style contract that converts a value or
  file into an artifact bundle.
- [ ] Support asynchronous converters and deterministic cleanup of streams,
  temporary files, or other resources.
- [ ] Select converters explicitly by value type or declared file extension.
- [ ] Prefer immutable, scoped converter registries over process-wide mutable
  registration.
- [ ] Allow format integrations to ship as optional packages without adding
  their dependencies to the core package.
- [ ] Specify stable artifact names and collision behavior for converters that
  emit multiple files.

### Structured value approvals

- [ ] Keep `verifyAsJson()` based on explicit JSON-compatible values and
  `toJson()` contracts; do not use mirrors.
- [ ] Propagate the original exception and object path when `toJson()` fails
  instead of reporting the value as merely unsupported.
- [ ] Add opt-in deterministic map-key ordering without silently changing
  existing approved JSON in 1.x.
- [ ] Add path-aware include, exclude, and scrub rules for structured values,
  such as `$.user.id`, before falling back to text regular expressions.
- [ ] Support type-specific value converters through the same immutable
  converter configuration used by artifact conversion.
- [ ] Detect cycles and report the first cyclic object path clearly.
- [ ] Provide opt-in, alias-preserving ID normalization by selected property
  path or name; do not scrub all numbers.

### File options and extensions

- [ ] Introduce an immutable file/artifact options model.
- [ ] Allow an artifact to declare its extension, such as `.json`, `.md`,
  `.csv`, or `.png`.
- [ ] Keep `.txt` as the default for all existing APIs.
- [ ] Normalize extensions consistently and reject path traversal or malformed
  values.
- [ ] Define an opt-in migration path for `verifyAsJson()` to produce
  `.approved.json`; do not rename existing approvals automatically in 1.x.

### Public writer verification

- [ ] Expose a supported `verifyWithWriter()` or artifact-based entry point.
- [ ] Let writers define how received content is produced without owning test
  naming or approval policy.
- [ ] Separate text headers from binary output so binary artifacts are never
  corrupted by generated comments.
- [ ] Preserve comparator and reporter selection through `Options`.
- [ ] Document how consumers implement custom writers.

### Existing file and binary approvals

- [ ] Add `verifyFile()` while preserving the source file extension.
- [ ] Add binary verification through the artifact/writer pipeline.
- [ ] Use binary-safe comparison for non-text artifacts.
- [ ] Avoid loading large files into memory when streaming or direct file
  comparison is sufficient.
- [ ] Write received artifacts atomically where practical.
- [ ] When a diff tool requires a valid file on first verification, create a
  format-valid empty counterpart where the format adapter can do so safely;
  never use an invalid zero-byte image as a universal placeholder.

### Reporter selection by artifact

- [ ] Allow reporters to declare supported artifact types or extensions.
- [ ] Prefer image-capable reporters for images and text diff tools for text.
- [ ] Fall back to opening the received file when no suitable diff reporter is
  installed.
- [ ] Keep GUI diff launch local-only by convention and default to a
  terminal-safe reporter on headless CI.

Acceptance criteria for Milestone 2:

- all existing `.approved.txt` tests pass without re-approval;
- text, JSON-extension, custom text writer, and binary examples are covered;
- one verification can report all mismatches across related text and binary
  artifacts;
- asynchronous writes, reporters, converter cleanup, and their failure paths
  are awaited and tested;
- missing approved binary artifacts produce a valid reviewable workflow;
- public extension points have dartdoc and complete examples;
- a migration guide explains any major-release naming changes.

## Milestone 3 — Scenarios, generated output, and CLI applications

### Pairwise combinations

- [ ] Add best-covering-pairs generation alongside full Cartesian verification.
- [ ] Keep full combinations as the explicit default.
- [ ] Include the selected/total scenario count in the approval output.
- [ ] Support labeled inputs and custom result formatting.
- [ ] Use property-based tests to prove every possible pair is covered.

Acceptance criteria:

- results are deterministic for the same ordered inputs;
- empty inputs, single-value parameters, duplicates, and large matrices are
  covered;
- benchmarks demonstrate the reduction in executed scenarios.

### Command approvals

- [ ] Add a command verification API for Dart and native CLI applications.
- [ ] Capture exit code, stdout, and stderr as separate labeled sections.
- [ ] Support stdin, working directory, environment overrides, and timeout.
- [ ] Pass executable and argument lists directly to `Process`; do not use a
  shell by default.
- [ ] Redact or scrub machine-specific paths from documented examples.

Acceptance criteria:

- success, non-zero exit, stderr-only, timeout, Unicode, and large-output cases
  are tested;
- environment inheritance and overrides are explicit;
- process cleanup is verified after timeout or cancellation.

### Storyboards

- [ ] Add a storyboard model for describing state over time.
- [ ] Support an optional title, an initial frame, named actions, and numbered
  frames.
- [ ] Accept a formatter rather than requiring domain objects to change their
  `toString()` implementation.
- [ ] Build on the normal approval pipeline and scrubbers.

Example output:

```text
Checkout

Initial:
items: 0
total: 0

Frame #1 — Add product:
items: 1
total: 25
```

### Directory approvals

- [ ] Verify every matching file in a directory.
- [ ] Detect added, removed, renamed, and changed relative paths.
- [ ] Support filters without depending on traversal order.
- [ ] Aggregate all mismatches instead of stopping at the first file.
- [ ] Produce a machine-readable mismatch manifest for CI.

## Milestone 4 — Configuration, review workflow, and documentation

### Scoped defaults

- [ ] Provide scoped defaults for repeated `Options` using Dart zones or an
  equivalent async-safe mechanism.
- [ ] Let call-specific options override scoped defaults.
- [ ] Restore the previous scope automatically after sync and async callbacks.
- [ ] Keep parallel test isolates and zones independent.

Do not introduce a mutable process-wide `Approvals.configure()` singleton.

### Review CLI

- [ ] Add structured `--json` output for tooling and CI.
- [ ] Add `--changed-only` based on explicit repository state.
- [ ] Define stable exit codes for no changes, rejected changes, invalid input,
  and tool failure.
- [ ] Support non-interactive listing and received-artifact manifests.
- [ ] Add explicit batch approve/reject commands with a dry run, deterministic
  file list, confirmation by default, and stable partial-failure reporting.
- [ ] Require a separate non-interactive confirmation flag for automation;
  never infer approval from the presence of CI.
- [ ] Keep approval itself explicit; do not make `--approve-all` a default CI
  workflow.

### CI integration

- [ ] Document GitHub Actions artifact upload for received files.
- [ ] Introduce typed mismatch data for missing, changed, unexpected, and
  reporter-failure cases rather than exposing only a formatted exception
  string.
- [ ] Emit one versioned JSON manifest for all mismatches in a test run.
- [ ] Include approved and received paths, artifact names and extensions, and
  mismatch kinds without leaking artifact contents.
- [ ] Avoid reporters that commit or push from a test process.
- [ ] Add examples for Linux, macOS, and Windows runners.

### Stale approval checks

- [ ] Add a read-only check for approved files that were not exercised by the
  current test run.
- [ ] Distinguish stale approvals from unexpected artifacts produced inside a
  multi-artifact verification.
- [ ] Provide machine-readable output and stable exit codes for CI.
- [ ] Never delete or approve files automatically; cleanup remains an explicit
  review action.
- [ ] Document limitations for filtered, sharded, or partially executed test
  suites so valid approvals are not reported as stale.

### Repository hygiene checks

- [ ] Add a read-only `check` command for approval repository conventions.
- [ ] Report received files that are tracked, approved files that are ignored,
  missing `.gitignore` coverage, invalid approval names, and incomplete
  approved/received pairs.
- [ ] Consume a complete-run manifest when checking stale approvals; refuse to
  claim completeness after a filtered or sharded run without merged manifests.
- [ ] Provide human-readable output, stable JSON output, and documented exit
  codes from the same typed findings.
- [ ] Keep fixes opt-in and show the exact proposed filesystem or Git change
  before applying it.

### Task-oriented documentation

- [ ] Add recipes for API responses, domain models, state machines, CLI tools,
  generated files, and legacy characterization tests.
- [ ] Add a decision table for `verify`, `verifyAsJson`, `verifyFile`, command
  approvals, storyboards, and Flutter approvals.
- [ ] Document custom scrubbers, writers, comparators, and reporters.
- [ ] Add migration guides for every breaking artifact or naming change.

## Experimental backlog

These features require evidence and isolated design work before entering a
release milestone.

### Inline approvals

- [ ] Prototype source-local expected strings for short text results.
- [ ] Generate a proposed Dart source file and open a diff rather than rewriting
  source silently.
- [ ] Handle multiline strings, raw strings, interpolation, formatter changes,
  multiple approvals, read-only CI, and concurrent tests.
- [ ] Consider a separate package until the workflow is proven stable.

### Format adapters

- [ ] Explore XML, HTML, Markdown-table, and CSV formatters as optional adapter
  packages.
- [ ] Keep parser/formatter dependencies out of the core package.
- [ ] Require deterministic ordering and explicit malformed-input behavior.

### Log approvals

- [ ] Document logger-agnostic capture patterns first.
- [ ] Add an adapter only for a stable logging abstraction with deterministic
  event ordering and PII-safe formatting.

### Scoped recording

- [ ] Prototype a zone-scoped recorder that lets instrumented code append
  named values to the current approval without returning them through every
  call layer.
- [ ] Keep recording opt-in and isolated between concurrent tests.
- [ ] Define deterministic ordering, duplicate-key behavior, pause/resume, and
  cleanup semantics.
- [ ] Require explicit filtering or redaction guidance for HTTP headers,
  database values, logs, and other potentially sensitive data.
- [ ] Keep this experimental until real HTTP, SQL, or logging integrations
  demonstrate that the hidden context is worth the complexity.

## Explicit non-goals

- A universal number scrubber that can hide meaningful business changes.
- Implicit approval of all received files in CI.
- Mandatory XML, HTML, image, or application-observability integrations in the
  core package.
- Global mutable configuration shared by parallel tests.
- Magic serialization of arbitrary Dart objects through reflection or mirrors.
- A process-wide mutable converter registry required by normal verification.
- Network-backed approval behavior in unit tests.
- Specialized verification methods that only rename `verify()` without adding
  format, execution, or artifact semantics.

Convenience API decisions:

| Proposed API | Decision |
| --- | --- |
| `verifyLines()` | Prefer improving/documenting `verifySequence()` unless line-specific formatting requirements emerge. |
| `verifyMap()` | Use `verifyAsJson()` with structured normalization. |
| `verifyXml()` | Provide through an optional deterministic XML adapter, not core. |
| `verifyMarkdown()` | Use normal text verification or an optional formatter when it adds stable structure. |
| `verifyException()` | Add because it owns execution and a distinct failure contract. |
| `verifyFile()` | Add because it preserves extensions and supports binary/streaming behavior. |
| `verifyCommand()` | Add because it owns process execution, timeout, exit code, stdout, and stderr. |

## Ordered delivery slices

Each slice must merge independently with green tests. Exact public names are
validated during API review, but responsibility stays within the listed files.

| Order | Deliverable | Primary files | Focused verification |
| --- | --- | --- | --- |
| 1 | Sequential and validated review CLI (complete) | `bin/review.dart`, `lib/src/cli/review_cli.dart`, `test/cli/review_cli_test.dart` | `dart test test/cli/review_cli_test.dart` |
| 2 | Explicit missing-approved policy (released in 1.5.0) and atomic text-write hardening (complete for 1.6.0) | `lib/src/core/options.dart`, `lib/src/approvals.dart`, `lib/src/writers/approval_text_writer.dart`, policy and writer tests | `dart test test/groups/approvals_test.dart test/writers/approval_text_writer_test.dart` |
| 3 | Safe names and collision diagnostics (complete for 1.6.0) | namers, final-path validation, typed exceptions, naming and collision tests | `dart test test/groups/namer.dart test/groups/approvals_test.dart` |
| 4 | Explicit `ApprovalContext` with legacy fallback | `lib/src/core/approval_context.dart`, `lib/src/approvals.dart`, `lib/src/core/approval_namer.dart`, context tests | `dart test test/groups/context_test.dart` |
| 5 | Awaited single-text verification path | `lib/src/core/verification_engine.dart`, `lib/src/approvals.dart`, reporter tests | `dart test test/groups/approvals_test.dart test/groups/reporter_arguments_test.dart` |
| 6 | Text and binary artifact model | `lib/src/artifacts/`, `lib/src/core/options.dart`, artifact tests | `dart test test/groups/artifact_test.dart` |
| 7 | Multi-artifact bundle and typed mismatch aggregation | `lib/src/artifacts/`, `lib/src/exceptions/`, bundle tests | `dart test test/groups/artifact_bundle_test.dart` |
| 8 | Typed and extension-based converters | `lib/src/converters/`, `lib/src/core/utils/converter.dart`, converter tests | `dart test test/groups/converter_tests.dart` |
| 9 | JSON manifest, stale checks, and repository checks | `bin/review.dart`, `bin/check.dart`, `lib/src/manifest/`, CLI tests | `dart test test/groups/manifest_test.dart test/groups/check_cli_test.dart` |
| 10 | Exceptions, commands, combinations, directories, and storyboards | dedicated files under `lib/src/approvals/` with matching tests | run each focused test, then the full suite |

### Completed slice verification

The 1.6.0 development tree passed the local gates on 2026-07-15:

- `dart format --output=none --set-exit-if-changed .` — no changes;
- `dart analyze` — no issues;
- full and randomized-order suites — all 166 test executions passed;
- executable library code — 100% line coverage (728/728 lines);
- `git diff --check` — clean, with no leftover temporary artifacts.

After every slice run:

```shell
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
```

Expected result: formatting exits `0`, analysis reports no issues, and all
tests pass on every supported Dart SDK and operating system in CI.

## Prior-art adoption matrix

| Prior-art capability | Dart decision | Roadmap location |
| --- | --- | --- |
| Verify: multiple files from one test | Adopt as one logical artifact bundle | Milestone 2 |
| Verify: converter/plugin pipeline | Adopt with explicit or scoped immutable registration | Milestone 2 |
| Verify: arbitrary object serialization | Adapt to `toJson`, JSON-compatible values, and explicit converters; no mirrors | Milestone 2 |
| Verify: no stack-trace dependency | Adopt through `ApprovalContext`; retain 1.x fallback | Milestone 1 |
| Verify: async by default | Adopt for the new pipeline; migrate 1.x additively | Milestone 2 |
| Verify: code-based configuration | Already present through immutable `Options`; add async-safe scopes | Milestone 4 |
| Verify: diff tool by default | Adapt as first-available local reporter with terminal CI fallback | Milestones 1–2 |
| Verify: recording | Prototype as zone-scoped and opt-in | Experimental backlog |
| Verify: dangling-file and repository checks | Adopt with complete-run safeguards | Milestone 4 |
| Verify: machine-readable failures | Adopt as typed mismatches plus versioned JSON | Milestone 4 |
| ApprovalTests.Swift: writers, file extensions, UI artifacts | Adopt writers/extensions in core; UI remains in Flutter | Milestone 2 and Flutter roadmap |
| ApprovalTests.Java: exception, pairwise, storyboard, directory, inline | Adopt all except inline remains experimental | Milestones 1–3 and experimental backlog |
| ApprovalTests.Python: binary/file/command approvals | Adopt through artifacts and safe process execution | Milestones 2–3 |
| ApprovalTests.cpp: scoped configuration | Adopt with zones, never process-wide mutable defaults | Milestone 4 |

## Quality and release gates

Every roadmap item must meet the following gates before release:

- [ ] Public APIs have dartdoc, examples, and explicit failure behavior.
- [ ] Business logic and error paths have focused tests.
- [ ] Executable library code maintains 100% line coverage, with failure and
  cleanup paths covered explicitly.
- [ ] `dart format` produces no changes.
- [ ] `dart analyze` reports no issues.
- [ ] The full test suite passes on supported Dart versions and platforms.
- [ ] `dart pub publish --dry-run` succeeds before a release.
- [ ] Snapshot or naming changes include migration instructions.
- [ ] Large artifacts or combination algorithms include benchmarks before
  optimization claims are made.
- [ ] No secrets, credentials, PII, or machine-specific paths are emitted by
  default.

## Prior art

This roadmap adapts proven ideas rather than copying another language's API:

- [ApprovalTests.Swift](https://github.com/approvals/ApprovalTests.Swift) —
  writers, verifiable objects, file extensions, reporter composition, and UI
  approvals.
- [ApprovalTests.Java](https://github.com/approvals/ApprovalTests.Java) —
  exception approvals, aliasing scrubbers, pairwise combinations, storyboards,
  directory approvals, and inline approvals.
- [ApprovalTests.Python](https://github.com/approvals/ApprovalTests.Python) —
  file/binary verification, command approvals, format helpers, pairwise
  combinations, and CI-oriented reporters.
- [ApprovalTests.cpp](https://github.com/approvals/ApprovalTests.cpp) — custom
  writers, artifact extensions, existing-file verification, and scoped
  configuration.
- [Verify](https://github.com/VerifyTests/Verify) — awaited verification,
  multi-artifact converters, explicit extension points, recording, typed
  integration output, and stale snapshot checks.
