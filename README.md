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
  <a href="http://www.apache.org/licenses/"><img src="https://img.shields.io/badge/license-APACHE-blue.svg" alt="License: APACHE"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart"><img src="https://hits.dwyl.com/approvals/ApprovalTests.Dart.svg?style=flat" alt="Repository views"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart"><img src="https://img.shields.io/github/stars/approvals/ApprovalTests.Dart?style=social" alt="Stars"></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/likes/approval_tests?logo=flutter" alt="Pub likes"></a>
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/popularity/approval_tests?logo=flutter" alt="Pub popularity"></a>
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/points/approval_tests?logo=flutter" alt="Pub points"></a>
</p>
<p align="center">
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/build_and_test.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/build_and_test.yml/badge.svg" alt="Build and test badge"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/publish.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/publish.yml/badge.svg" alt="Deploy and Create Release"></a>
  <a href="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/mdsnippets.yml"><img src="https://github.com/approvals/ApprovalTests.Dart/actions/workflows/mdsnippets.yml/badge.svg" alt="mdsnippets"></a>
</p>

## 📖 About

**[Approval Tests](https://approvaltests.com/)** are an alternative to assertions. You’ll find them useful for testing objects with complex values *(such as long strings)*, lots of properties, or collections of objects.

`Approval tests` simplify this by taking a snapshot of the results, and confirming that they have not changed.   

In normal unit testing, you say `expect(person.getAge(), 5)`. Approvals allow you to do this when the thing that you want to assert is no longer a primitive but a complex object. For example, you can say, `Approvals.verify(person)`.

I am writing an implementation of **[Approval Tests](https://approvaltests.com/)** in Dart. If anyone wants to help, please **[text](https://t.me/yelmuratoff)** me. 🙏

## Packages
ApprovalTests is designed for two level: Dart and Flutter. <br>

| Package | Version | Description | 
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [approval_tests](https://github.com/approvals/ApprovalTests.Dart/tree/main/packages/approval_tests) | [![Pub](https://img.shields.io/pub/v/approval_tests.svg?style=flat-square)](https://pub.dev/packages/approval_tests) | **Dart** package for approval testing of `unit` tests *(main)* |
| [approval_tests_flutter](https://github.com/approvals/ApprovalTests.Dart/tree/main/packages/approval_tests_flutter) | [![Pub](https://img.shields.io/pub/v/approval_tests_flutter.svg)](https://pub.dev/packages/approval_tests_flutter) | **Flutter** package for approval testing of `widget`, `integration` tests |


## 📋 How it works

- The first run of the test automatically creates an `approved` file if there is no such file.
- If the changed results match the `approved` file perfectly, the test passes.
- If there's a difference, a `reporter` tool will highlight the mismatch and the test fails.
- If the test is passed, the `received` file is deleted automatically. You can change this by changing the `deleteReceivedFile` value in `options`. If the test fails, the received file remains for analysis.

## 📦 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  approval_tests: ^1.1.5
```

## 👀 Getting Started

The best way to get started is to download and open the starter project:
* [Approvaltests.Dart.StarterProject](https://github.com/approvals/Approvaltests.Dart.StarterProject)

This is a standard project that can be imported into any editor or IDE and also includes CI with GitHub Actions.

It comes ready with:

- A suitable `.gitignore` to exclude approval artifacts
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

#### • Via approveResult property
If you want the result to be automatically saved after running the test, you need to use the `approveResult` property in `Options`:

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
{
  "name": "JsonTest",
  "features": [
    "Testing",
    "JSON"
  ],
  "version": 0.1
}
```
<sup><a href='/test/example/example_test.test_JSON_object.approved.txt#L1-L8' title='Snippet source file'>snippet source</a> | <a href='#snippet-example_test.test_JSON_object.approved.txt' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

#### • Via file rename
You can just rename the `.received` file to `.approved`.

### Reporters

Reporters are the part of Approval Tests that launch diff tools when things do not match. They are the part of the system that makes it easy to see what has changed.

There are several reporters available in the package:
- `CommandLineReporter` - This is the default reporter, which will output the diff in the terminal.
- `GitReporter` - This reporter will open the diff in the Git GUI.
- `DiffReporter` - This reporter will open the Diff Tool in your IDE.
   - For Diff Reporter I using the default paths to the IDE, if something didn't work then you in the console see the expected correct path to the IDE and specify customDiffInfo. You can also contact me for help.

<img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_command_line.png?raw=true" alt="CommandLineComparator img" title="ApprovalTests" style="max-width: 500px;">


To use `DiffReporter` you just need to add it to `options`:
```dart
 options: const Options(
   reporter: const DiffReporter(),
 ),
```

<div style="display: flex; justify-content: center; align-items: center;">
  <img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_tool_vs_code.png?raw=true" alt="Visual Studio code img" style="width: 45%;margin-right: 1%;" />
  <img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/diff_tool_studio.png?raw=true" alt="Android Studio img" style="width: 45%;" />
</div>


## 📝 Examples

I have provided a couple of small examples here to show you how to use the package.
There are more examples in the `example` folder for you to explore. I will add more examples in the future.
Inside, in the `gilded_rose` folder, there is an example of using `ApprovalTests` to test the legacy code of [Gilded Rose kata](https://github.com/emilybache/GildedRose-Refactoring-Kata).
You can study it to understand how to use the package to test complex code.

And the `verify_methods` folder has small examples of using different `ApprovalTests` methods for different cases.

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
    Approvals.verifyAsJson(
      jsonItem,
      options: const Options(
        deleteReceivedFile:
            true, // Automatically delete the received file after the test.
        approveResult:
            true, // Approve the result automatically. You can remove this property after the approved file is created.
      ),
    );
  });
}
```
<sup><a href='/example/verify_methods/verify_as_json/verify_as_json_test.dart#L6-L34' title='Snippet source file'>snippet source</a> | <a href='#snippet-same_verify_as_json_test_with_model' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

this will result in the following file
`verify_as_json_test.verify_model.approved.txt`
<!-- snippet: verify_as_json_test.verify_model.approved.txt -->
<a id='snippet-verify_as_json_test.verify_model.approved.txt'></a>
```txt
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
<sup><a href='/example/verify_methods/verify_as_json/verify_as_json_test.verify_model.approved.txt#L1-L24' title='Snippet source file'>snippet source</a> | <a href='#snippet-verify_as_json_test.verify_model.approved.txt' title='Start of snippet'>anchor</a></sup>
<!-- endSnippet -->

<img src="https://github.com/yelmuratoff/packages_assets/blob/main/assets/approval_tests/passed.png?raw=true" alt="Passed test example" title="ApprovalTests" style="max-width: 800px;">


## ❓ Which File Artifacts to Exclude from Source Control
You must add any `approved` files to your source control system. But `received` files can change with any run and should be ignored. For Git, add this to your `.gitignore`:

```gitignore
*.received.*
```

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
