<div align="center">
<p align="center">
    <a href="https://github.com/K1yoshiSho/approval_tests" align="center">
        <img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/approval_tests.png?raw=true" width="400px">
    </a>
</p>
</div>

<h2 align="center"> Approval Tests implementation in Dart 🚀 </h2>
<br>
<p align="center">
  <a href="https://pub.dev/packages/approval_tests"><img src="https://img.shields.io/pub/v/approval_tests.svg" alt="Pub"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://github.com/K1yoshiSho/approval_tests"><img src="https://hits.dwyl.com/K1yoshiSho/approval_tests.svg?style=flat" alt="Repository views"></a>
  <a href="https://github.com/K1yoshiSho/approval_tests"><img src="https://img.shields.io/github/stars/K1yoshiSho/approval_tests?style=social" alt="Pub"></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/likes/approval_tests?logo=flutter" alt="Pub likes"></a>
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/popularity/approval_tests?logo=flutter" alt="Pub popularity"></a>
  <a href="https://pub.dev/packages/approval_tests/score"><img src="https://img.shields.io/pub/points/approval_tests?logo=flutter" alt="Pub points"></a>
</p>

## 📖 About

Unit testing asserts can be **difficult** to use. `Approval tests` simplify this by taking a snapshot of the results, and confirming that they have not changed.   

In normal unit testing, you say `expect(person.getAge(), 5)`. Approvals allow you to do this when the thing that you want to assert is no longer a primitive but a complex object. For example, you can say, `Approvals.verify(person)`.

I am writing an implementation of a great tool like **[Approval Tests](https://approvaltests.com/)** in Dart. If anyone wants to help, please **[text](https://t.me/yelmuratoff)** me. 🙏

<!-- At the moment the package is **in development** and <u>not ready</u> to use. 🚧 -->

## 📦 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  approval_tests: ^0.3.2-dev
```

## 📚 How to use

### Approving Results

Approving results just means saving the `.approved.txt` file with your desired results.

We’ll provide more explanation in due course, but, briefly, here are the most common approaches to do this.

#### • Via Diff Tool
Most diff tools have the ability to move text from left to right, and save the result.
How to use diff tools is just below, there is a `Comparator` class for that.

#### • Via approveResult property
If you want the result to be automatically saved after running the test, you need to use the `approveResult` property in `Options`:

```dart
test('test complex JSON object', () {
  var complexObject = {
    'name': 'JsonTest',
    'features': ['Testing', 'JSON'],
    'version': 0.1,
  };
  ApprovalTests.verifyAsJson(
    complexObject,
    options: const Options(
      approveResult: true,
    ),
  );
});
```

#### • Via file rename
You can just rename the `.received` file to `.approved`.

### Comparators

You can use different comparators to compare files. The default is `CommandLineComparator` which compares files in the console.

<img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/diff_command_line.png?raw=true" alt="CommandLineComparator img" title="ApprovalTests" style="max-width: 500px;">


To use `IDEComparator` you just need to add it to `options`:
```dart
 options: const Options(
   comparator: IDEComparator(
      ide: ComparatorIDE.visualStudioCode,
   ),
 ),
```

But before you add an `IDEComparator` you need to do the initial customization:

- **Visual Studio Code**
  - For this method to work, you need to have Visual Studio Code installed on your machine.
  - And you need to have the `code` command available in your terminal.
  - To enable the `code` command, press `Cmd + Shift + P` and type `Shell Command: Install 'code' command in PATH`.

- **IntelliJ IDEA**
   - For this method to work, you need to have IntelliJ IDEA installed on your machine.
   - And you need to have the `idea` command available in your terminal.
   - To enable the `idea` command, you need to create the command-line launcher using `Tools - Create Command-line Launcher` in IntelliJ IDEA.

- **Android Studio**
   - For this method to work, you need to have Android Studio installed on your machine.
   - And you need to have the `studio` command available in your terminal.
   - To enable the `studio` command, you need to create the command-line launcher using `Tools - Create Command-line Launcher` in Android Studio.

<div style="display: flex; justify-content: center; align-items: center;">
  <img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/diff_tool_vs_code.png?raw=true" alt="Visual Studio code img" style="width: 45%;margin-right: 1%;" />
  <img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/diff_tool_studio.png?raw=true" alt="Android Studio img" style="width: 45%;" />
</div>


## 📝 Examples

I have provided a couple of small examples here to show you how to use the package.
There are more examples in the `example` folder for you to explore. I will add more examples in the future.
Inside, in the `gilded_rose` folder, there is an example of using `ApprovalTests` to test the legacy code of [Gilded Rose kata](https://github.com/emilybache/GildedRose-Refactoring-Kata).
You can study it to understand how to use the package to test complex code.

And the `verify_methods` folder has small examples of using different `ApprovalTests` methods for different cases.

### JSON example

```dart
import 'package:approval_tests/approval_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Verify JSON output of an object', () {
    var item = Item(
      id: 1,
      name: "Widget",
      anotherItem: AnotherItem(id: 1, name: "AnotherWidget"),
      subItem: SubItem(
        id: 1,
        name: "SubWidget",
        anotherItems: [
          AnotherItem(id: 1, name: "AnotherWidget1"),
          AnotherItem(id: 2, name: "AnotherWidget2"),
        ],
      ),
    );

    ApprovalTests.verifyAsJson(
      item,
    );
  });
}

/// Item class for testing
class Item {
  final int id;
  final String name;
  final SubItem subItem;
  final AnotherItem anotherItem;

  Item({
    required this.id,
    required this.name,
    required this.subItem,
    required this.anotherItem,
  });
}

/// Sub item class for testing
class SubItem {
  final int id;
  final String name;
  final List<AnotherItem> anotherItems;

  SubItem({
    required this.id,
    required this.name,
    required this.anotherItems,
  });
}

/// Another item class for testing
class AnotherItem {
  final int id;
  final String name;

  AnotherItem({required this.id, required this.name});
}
```

<img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/passed.png?raw=true" alt="Passed test example" title="ApprovalTests" style="max-width: 800px;">


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

## 🤝 Contributing
Show some 💙 and <a href="https://github.com/K1yoshiSho/approval_tests.git">star the repo</a> to support the project! 🙌   
The project is in the process of development and we invite you to contribute through pull requests and issue submissions. 👍   
We appreciate your support. 🫰

<br><br>
<div align="center" >
  <p>Thanks to all contributors of this package</p>
  <a href="https://github.com/K1yoshiSho/approval_tests/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=K1yoshiSho/approval_tests" />
  </a>
</div>
<br>