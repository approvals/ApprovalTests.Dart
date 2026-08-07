<div align="center">
<p align="center">
    <a href="https://github.com/approvals/ApprovalTests.Dart" align="center">
        <img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/approval_tests.png?raw=true" width="400px">
    </a>
</p>
</div>

<h2 align="center"> Approval Tests implementation in Dart 🚀 </h2>
<br>
<p align="center">
  <a href="https://app.codecov.io/gh/approvals/ApprovalTests.Dart"><img src="https://codecov.io/gh/approvals/ApprovalTests.Dart/branch/main/graph/badge.svg" alt="codecov"></a>
  <a href="https://pub.dev/packages/approval_tests"><img src="https://img.shields.io/pub/v/approval_tests.svg" alt="Pub"></a>
  <a href="https://www.apache.org/licenses/"><img src="https://img.shields.io/badge/license-APACHE-blue.svg" alt="License: APACHE"></a>
  <!-- <a href="https://github.com/approvals/ApprovalTests.Dart"><img src="https://hits.dwyl.com/approvals/ApprovalTests.Dart.svg?style=flat" alt="Repository views"></a> -->
  <a href="https://github.com/approvals/ApprovalTests.Dart"><img src="https://img.shields.io/github/stars/approvals/ApprovalTests.Dart?style=social" alt="Stars"></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/likes/approval_tests?logo=flutter" alt="Pub likes"></a>
  <!-- <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/popularity/approval_tests?logo=flutter" alt="Pub popularity"></a> -->
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/points/approval_tests?logo=flutter" alt="Pub points"></a>
</p>
<p align="center">
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/build_and_test.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/build_and_test.yml/badge.svg" alt="Build and test badge"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/publish.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/publish.yml/badge.svg" alt="Deploy and Create Release"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/mdsnippets.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/mdsnippets.yml/badge.svg" alt="mdsnippets"></a>
</p>

## 📖 About

**[Approval Tests](https://approvaltests.com/)** are an alternative to assertions. You’ll find them useful for testing objects with complex values _(such as long strings)_, lots of properties, or collections of objects.

`Approval tests` simplify this by taking a snapshot of the results, and confirming that they have not changed.

In normal unit testing, you say `expect(person.getAge(), 5)`. Approvals allow you to do this when the thing that you want to assert is no longer a primitive but a complex object. `Approvals.verify()` accepts text; for a model with a `toJson()` method, use `Approvals.verifyAsJson(person.toJson())`.

I am writing an implementation of **[Approval Tests](https://approvaltests.com/)** in Dart. If anyone wants to help, please **[text](https://t.me/yelmuratoff)** me. 🙏

## Packages

ApprovalTests is designed for two level: Dart and Flutter. <br>

| Package                                                                           | Version                                                                                                              | Description                                                               |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| [approval_tests](https://github.com/approvals/ApprovalTests.Dart)                 | [![Pub](https://img.shields.io/pub/v/approval_tests.svg?style=flat-square)](https://pub.dev/packages/approval_tests) | **Dart** package for approval testing of `unit` tests _(main)_            |
| [approval_tests_flutter](https://github.com/approvals/ApprovalTests.Dart.Flutter) | [![Pub](https://img.shields.io/pub/v/approval_tests_flutter.svg)](https://pub.dev/packages/approval_tests_flutter)   | **Flutter** package for approval testing of `widget`, `integration` tests |

Testing Flutter UI? Start with the
[Flutter package guide](https://github.com/approvals/ApprovalTests.Dart.Flutter)
and its executable
[state-management example](https://github.com/approvals/ApprovalTests.Dart.Flutter/tree/main/example/flutter_example).

## 📋 How it works

- The first run of the test automatically creates an `approved` file if there is no such file.
- If the changed results match the `approved` file perfectly, the test passes.
- If there's a difference, a `reporter` tool will highlight the mismatch and the test fails.
- If the test is passed, the `received` file is deleted automatically. You can change this by changing the `deleteReceivedFile` value in `options`. If the test fails, the received file remains for analysis.

### Missing approved files

The default policy preserves the 1.x first-run workflow: verification creates
the missing approved file and passes. Use strict mode when verification must
never create or update approved artifacts, such as in CI:

```dart
Approvals.verify(
  response,
  options: const Options(
    missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
  ),
);
```

Strict mode writes a reviewable received file and throws a
`DoesntMatchException` whose `kind` is
`ApprovalMismatchKind.missingApproved`. Generate or approve the expected file
locally after reviewing it; `dart run approval_tests:review` is the preferred
review workflow. The `approveResult` option is a deliberate local migration
tool and is ignored by strict mode so verification cannot mutate an approved
artifact.

### Safe artifact names

Test names, descriptions, custom file names, and final artifact names are
validated as filename segments. `/` and `\` are rejected with
`InvalidApprovalNameException` instead of being interpreted as directories.
Control characters, Windows-invalid characters, trailing dots or spaces, and
reserved names such as `CON` are normalized consistently on every platform.
Existing valid names remain unchanged.

Generated filename segments are limited to 255 UTF-8 bytes. Longer names keep
a readable prefix and receive a stable 16-character hash while preserving the
artifact extension. If two verifications in one loaded test suite target the
same normalized path, the second fails before writing with
`ApprovalPathCollisionException`; the exception exposes the path and both
verification identities.

Approved and received paths are validated and claimed together before any
artifact is written. If either path is invalid, neither path remains claimed.
When one test performs several logical approvals, give each verification a
unique description or use `IndexedNamer` so their artifact paths do not
collide.

### Atomic text artifacts

`ApprovalTextWriter` writes to a same-directory temporary file, flushes it,
and atomically replaces the destination. Concurrent readers therefore observe
either the previous complete artifact or the new complete artifact, never a
partially written file. On Windows, transient access, sharing, and lock
violations caused by concurrent readers are retried with a bounded attempt
count. Temporary files are cleaned up if replacement fails.

### Explicit verification context

By default, approval naming infers two things implicitly: the source file, by
parsing `StackTrace.current`, and the test name, from `package:test`'s
internals. Both work under `dart test`, but neither can be supplied by a custom
runner, a generated harness, or a transformed stack trace.

`ApprovalContext` makes naming explicit. Pass it to the namer:

```dart
Approvals.verify(
  report,
  options: Options(
    namer: Namer(
      context: ApprovalContext(
        sourcePath: 'test/billing/invoice_test.dart',
        testName: 'renders a paid invoice',
      ),
    ),
  ),
);
```

The context lives on the namer rather than on `Options` because `IndexedNamer`
allocates its counter while being constructed, before `Options` reaches
`Approvals`. A context supplied later would name files after one test while
numbering them after another.

Resolution is per field, so a context can be partial:

| Field        | When supplied                                      | When omitted                                 |
| ------------ | -------------------------------------------------- | -------------------------------------------- |
| `sourcePath` | artifacts are named after it and written beside it | the stack trace is parsed, exactly as before |
| `testName`   | included in the artifact name                      | the ambient test name is used                |

An explicit `sourcePath` never overrides an explicit `Namer.filePath`, and an
explicit `testName` that differs from the ambient one is a supported override,
not an error.

Inference remains the 1.x fallback, so existing approvals keep their names
byte for byte. The one new error is a context that supplies no `testName` while
no test framework is active and `addTestName` is `true`: every verification in
the file would otherwise collapse onto a single artifact name, so it fails with
`InvalidApprovalNameException` instead.

Custom namers are unaffected. `ApprovalContext` support is a separate
`ContextAwareNamer` capability, so an existing `implements ApprovalNamer`
compiles and behaves unchanged.

## 📦 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  approval_tests: ^1.7.1
```

These docs target the 1.7.1 release. Dart 3.6 or newer has been
required since 1.5.0 because the internal console logger uses
`ispectify 6.1.2`.

## 👀 Getting Started

The best way to get started is to download and open the starter project:

- [Approvaltests.Dart.StarterProject](https://github.com/approvals/Approvaltests.Dart.StarterProject)

This is a standard project that can be imported into any editor or IDE and also includes CI with GitHub Actions.

It comes ready with:

- A suitable `.gitignore` that ignores received artifacts while keeping
  approved artifacts under source control
- A ready linter with all rules in place
- A GitHub action to run tests and you can always check the status of the tests on the badge in the `README.md` file.

## 📚 How to use

In order to use `Approval Tests`, the user needs to:

1. Set up a test: This involves importing the Approval Tests library into your own code.

2. Optionally, set up a reporter: Reporters are tools that highlight differences between approved and received files when a test fails. Although not necessary, they make it significantly easier to see what changes have caused a test to fail. The default reporter is the `CommandLineReporter`. You can also use the `DiffReporter` to compare the files in your IDE, and the `GitReporter` to see the differences in the `Git GUI`.

3. Manage the `approved` file: When the test is run for the first time, an approved file is created automatically. This file will represent the expected outcome. Once the test results in a favorable outcome, the approved file should be updated to reflect these changes. A little bit below I wrote how to do it.

This setup is useful because it shortens feedback loops, saving developers time by only highlighting what has been altered rather than requiring them to parse through their entire output to see what effect their changes had.

### Approving Results

Approving results just means saving the `.approved.txt` file with your desired results.

We’ll provide more explanation in due course, but, briefly, here are the most common approaches to do this.

#### • Via Diff Tool

Most diff tools have the ability to move text from left to right, and save the result.
How to use diff tools is just below, there is a `Comparator` class for that.

#### • Via CLI command

You can run the command in a terminal to review your files:

```bash
dart run approval_tests:review
```

After running the command, the files will be analyzed and you will be asked to choose one of the options:

- `y` - Approve the received file.
- `n` - Reject the received file.
- `v`iew - View the differences between the received and approved files. After selecting `v` you will be asked which IDE you want to use to view the differences.

With no arguments, the command discovers supported `.received.txt` files,
sorts them by normalized relative path, and reviews them one at a time so only
one terminal prompt is active. `--list` prints that same deterministic order;
you can then pass an index or a path from the list. Paths must identify an
existing `.received.txt` file. Diff tools are awaited, so launch and execution
failures are reported instead of being silently ignored.

#### • Via approveResult property

If you want the result to be automatically saved after running the test, you need to use the `approveResult` property in `Options`:

> `approveResult` is intended for a deliberate, local migration or initial
> snapshot-generation step. Remove it after reviewing the generated file, and
> never enable it in normal CI: CI should verify approved artifacts, not mutate
> them.

<!-- snippet: sample_verify_as_json_test -->
<a id='snippet-sample_verify_as_json_test'></a>
```dart
void main() {
  test('test JSON object', () {
    final complexObject = {
      'name': 'JsonTest',
      'features': ['Testing', 'JSON'],
      'version': 0.1,
    };

    Approvals.verifyAsJson(
      complexObject,
      options: const Options(
        approveResult: true,
      ),
    );
  });
}
```
<sup><a href='/test/example/example_test.dart#L4-L21' title='Snippet source file'>snippet source</a> | <a href='#snippet-sample_verify_as_json_test' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

this will result in the following file
`example_test.test_JSON_object.approved.txt`

<!-- snippet: example_test.test_JSON_object.approved.txt -->
<a id='snippet-example_test.test_JSON_object.approved.txt'></a>
```txt
# This file was generated by approval_tests. Please do not edit.

{
  "name": "JsonTest",
  "features": [
    "Testing",
    "JSON"
  ],
  "version": 0.1
}
```
<sup><a href='/test/example/example_test.test_JSON_object.approved.txt#L1-L10' title='Snippet source file'>snippet source</a> | <a href='#snippet-example_test.test_JSON_object.approved.txt' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

#### • Via file rename

You can just rename the `.received` file to `.approved`.

### Reporters

Reporters are the part of Approval Tests that launch diff tools when things do not match. They are the part of the system that makes it easy to see what has changed.

There are several reporters available in the package:

- `CommandLineReporter` - This is the default reporter, which will output the diff in the terminal.
- `GitReporter` - This reporter will open the diff in the Git GUI using `git diff --no-index`. Each argument is provided separately to Git and any exit code greater than `1` is surfaced as a failure, so unexpected tool errors are easier to spot. Provide a custom `DiffInfo` if you need extra arguments (for example, `DiffInfo(command: 'git', arg: 'diff --no-index --word-diff')`).
- `DiffReporter` - This reporter will open the Diff Tool in your IDE. Arguments are tokenized automatically, so values such as `-d --wait` can be supplied in the `DiffInfo.arg` string without additional escaping.
  - For Diff Reporter I using the default paths to the IDE, if something didn't work then you in the console see the expected correct path to the IDE and specify customDiffInfo. You can also contact me for help.
- `FirstWorkingReporter` - Reports through the first of its entries that is available here, so one configuration works both locally and on headless CI.
- `MultiReporter` - Reports through every available entry, sequentially and in declaration order.

<img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_command_line.png?raw=true" alt="CommandLineComparator img" title="ApprovalTests" style="max-width: 500px;">

To use `DiffReporter` you just need to add it to `options`:

```dart
 options: const Options(
   reporter: const DiffReporter(),
 ),
```

#### Composing reporters

A diff tool that is installed locally is usually absent on CI. Rather than
branching on the environment, compose reporters and let the package pick:

```dart
options: const Options(
  reporter: FirstWorkingReporter([
    DiffReporter(),
    CommandLineReporter(),
  ]),
),
```

`FirstWorkingReporter` consults each entry in declaration order and reports
through the first available one, so the same `Options` open a diff tool locally
and print to the terminal on a headless runner. `CommandLineReporter` is always
available, which makes it the natural last entry.

Availability answers only "can this reporter run here" — a missing executable
or an unsupported platform. A reporter that _is_ available but then fails is
never silently skipped: its error propagates, so a broken diff tool is not
mistaken for a successful report. When no entry is available at all,
`FirstWorkingReporter` throws `NoAvailableReporterException`.

Use `MultiReporter` to notify several reporters for the same mismatch:

```dart
options: const Options(
  reporter: MultiReporter([
    CommandLineReporter(),
    GitReporter(),
  ]),
),
```

`MultiReporter` runs its entries sequentially in declaration order, so console
output cannot interleave, and skips unavailable ones. Every entry runs even if
an earlier one fails; the first failure is rethrown once the rest have run and
later failures are logged. Reporting through zero available reporters completes
normally.

Custom reporters keep working unchanged: a `Reporter` that does not implement
the `ReporterAvailability` contract is treated as always available. Implement
`ReporterAvailability` when your reporter depends on an external tool:

```dart
final class MyReporter implements ReporterAvailability {
  const MyReporter();

  @override
  bool get isAvailable => ApprovalUtils.isFileExists('/usr/local/bin/my-diff');

  @override
  Future<void> report(String approvedPath, String receivedPath) async { ... }
}
```

The default `Options.reporter` is still `CommandLineReporter`; composition is
opt-in.

### Console diagnostics

Approval Tests emits compact, typed console diagnostics through `ispectify`.
Exceptions retain their original stack traces, while in-memory log history is
disabled so test runs do not accumulate diagnostic events. This internal
logging change does not alter approved or received file contents and requires
no application-level logger setup.

<div style="display: flex; justify-content: center; align-items: center;">
  <img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_tool_vs_code.png?raw=true" alt="Visual Studio code img" style="width: 45%;margin-right: 1%;" />
  <img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_tool_studio.png?raw=true" alt="Android Studio img" style="width: 45%;" />
</div>

### Scrubber pipelines

Use `CompositeScrubber` when a snapshot contains more than one kind of
volatile value. Scrubbers run in the order they are supplied:

```dart
Approvals.verify(
  response,
  options: Options(
    scrubber: CompositeScrubber([
      const ScrubDates(),
      const ScrubWithRegEx(),
    ]),
  ),
);
```

Use aliases when repeated volatile values carry meaning. The same source value
receives the same alias within one `scrub()` call, while distinct values are
numbered by first appearance. Alias state resets for every call.

```dart
Approvals.verify(
  response,
  options: Options(
    scrubber: CompositeScrubber([
      const ScrubUuids(),
      const ScrubWithAliases(
        pattern: r'user-\d+',
        alias: 'user',
      ),
    ]),
  ),
);
```

`ScrubUuids` treats case variants of a canonical UUID as the same value.
`ScrubWithAliases` is case-sensitive by default; set `caseSensitive: false`
when case should not affect alias identity.

## 📝 Examples

I have provided a couple of small examples here to show you how to use the package.
There are more examples in the `example` folder for you to explore. I will add more examples in the future.
Inside, in the `gilded_rose` folder, there is an example of using `ApprovalTests` to test the legacy code of [Gilded Rose kata](https://github.com/emilybache/GildedRose-Refactoring-Kata).
You can study it to understand how to use the package to test complex code.

And the `verify_methods` folder has small examples of using different `ApprovalTests` methods for different cases.

### Network query example

`NetworkRequestQuery` now supports stubbed responses so approval files can be generated deterministically without a live HTTP request. You can still call real services, but the default constructor parameters return a cached payload for the provided URI:

```dart
final query = NetworkRequestQuery(
  Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
  stubbedResponses: {
    Uri.parse('https://jsonplaceholder.typicode.com/todos/1'): {
      'id': 1,
      'status': 'OK',
    },
  },
);

await Approvals.verifyQuery(query);
```

`example/verify_methods/verify_query/verify_network_query_test.dart` demonstrates how to plug the query into an approval test.

### JSON example

With `verifyAsJson`, if you pass data models as `JsonItem`, with nested other models as `AnotherItem` and `SubItem`, then you need to add an `toJson` method to each model for the serialization to succeed.

<!-- snippet: same_verify_as_json_test_with_model -->
<a id='snippet-same_verify_as_json_test_with_model'></a>
```dart
void main() {
  const jsonItem = JsonItem(
    id: 1,
    name: "JsonItem",
    anotherItem: AnotherItem(id: 1, name: "AnotherItem"),
    subItem: SubItem(
      id: 1,
      name: "SubItem",
      anotherItems: [
        AnotherItem(id: 1, name: "AnotherItem 1"),
        AnotherItem(id: 2, name: "AnotherItem 2"),
      ],
    ),
  );

  test('verify model', () {
    Approvals.verifyAsJson(jsonItem);
  });
}
```
<sup><a href='/example/verify_methods/verify_as_json/verify_as_json_test.dart#L6-L26' title='Snippet source file'>snippet source</a> | <a href='#snippet-same_verify_as_json_test_with_model' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

this will result in the following file
`verify_as_json_test.verify_model.approved.txt`

<!-- snippet: verify_as_json_test.verify_model.approved.txt -->
<a id='snippet-verify_as_json_test.verify_model.approved.txt'></a>
```txt
# This file was generated by approval_tests. Please do not edit.

{
  "jsonItem": {
    "id": 1,
    "name": "JsonItem",
    "subItem": {
      "id": 1,
      "name": "SubItem",
      "anotherItems": [
        {
          "id": 1,
          "name": "AnotherItem 1"
        },
        {
          "id": 2,
          "name": "AnotherItem 2"
        }
      ]
    },
    "anotherItem": {
      "id": 1,
      "name": "AnotherItem"
    }
  }
}
```
<sup><a href='/example/verify_methods/verify_as_json/verify_as_json_test.verify_model.approved.txt#L1-L26' title='Snippet source file'>snippet source</a> | <a href='#snippet-verify_as_json_test.verify_model.approved.txt' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

<img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/passed.png?raw=true" alt="Passed test example" title="ApprovalTests" style="max-width: 800px;">

## ❓ Which File Artifacts to Exclude from Source Control

Commit every `*.approved.*` artifact: it is the reviewed test expectation.
Ignore every `*.received.*` artifact because it is regenerated when a
verification fails. For Git, use:

```gitignore
*.received.*
```

Do not add `*.approved.*` to `.gitignore`.

## ✉️ For More Information

### Questions?

Ask me on Telegram: [`@yelmuratoff`](https://t.me/yelmuratoff).  
Email: [`yelamanyelmuratov@gmail.com`](mailto:yelamanyelmuratov@gmail.com)

### Video Tutorials

- [Getting Started with ApprovalTests.Swift](https://qualitycoding.org/approvaltests-swift-getting-started/)
- [How to Verify Objects (and Simplify TDD)](https://qualitycoding.org/approvaltests-swift-verify-objects/)
- [Verify Arrays and See Simple, Clear Diffs](https://qualitycoding.org/verify-arrays-approvaltests-swift/)
- [Write Parameterized Tests by Transforming Sequences](https://qualitycoding.org/parameterized-tests-approvaltests-swift/)
- [Wrangle Legacy Code with Combination Approvals](https://qualitycoding.org/wrangle-legacy-code-combination-approvals/)

You can also watch a series of short videos about [using ApprovalTests in .Net](https://www.youtube.com/playlist?list=PL0C32F89E8BBB5368) on YouTube.

### Podcasts

Prefer learning by listening? Then you might enjoy the following podcasts:

- [Hanselminutes](https://www.hanselminutes.com/360/approval-tests-with-llewellyn-falco)
- [Herding Code](https://www.developerfusion.com/media/122649/herding-code-117-llewellyn-falcon-on-approval-tests/)
- [The Watir Podcast](https://watirpodcast.com/podcast-53/)

## Coverage

The 1.7.1 release has 100% line coverage for executable code under `lib`
(792/792 lines). The full suite passes all 256 test executions.

To reproduce the line-coverage report locally:

```shell
dart pub global activate coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage \
  --packages=.dart_tool/package_config.json \
  --report-on=lib \
  --lcov \
  -o coverage/lcov.info \
  -i coverage
```

[![](https://codecov.io/gh/approvals/ApprovalTests.Dart/branch/main/graphs/sunburst.svg)](https://codecov.io/gh/approvals/ApprovalTests.Dart/branch/main)

## 🤝 Contributing

Show some 💙 and <a href="https://github.com/approvals/ApprovalTests.Dart.git">star the repo</a> to support the project! 🙌  
The project is in the process of development and we invite you to contribute through pull requests and issue submissions. 👍  
We appreciate your support. 🫰

<br><br>

<div align="center" >
  <p>Thanks to all contributors of this package</p>
  <a href="https://github.com/approvals/ApprovalTests.Dart/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=approvals/ApprovalTests.Dart" />
  </a>
</div>
<br>
