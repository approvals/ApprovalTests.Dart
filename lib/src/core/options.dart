part of '../../approval_tests.dart';

/// `Options` class is a class used to set options for the approval test.
class Options {
  /// A final bool variable `isScrub` used to determine if the input should be scrubbed.
  final bool isScrub;

  /// A final variable `comparator` of type `Comparator` used to compare the approved and received files.
  final Comparator comparator;

  /// A final bool variable `approveResult` used to determine if the result should be approved after the test.
  final bool approveResult;

  /// Path to the files: `approved` and `received`.
  final String? filesPath;

  /// Number of the line.
  final int? line;

  /// A final bool variable `deleteReceivedFile` used to determine if the received file should be deleted after passed test.
  final bool deleteReceivedFile;

  /// A final variable `namer` of type `Namer` used to set the name and path of the file.
  final Namer? namer;

  /// A final bool variable `logErrors` used to determine if the errors should be logged.
  final bool logErrors;

  /// A final bool variable `logResults` used to determine if the results should be logged.
  final bool logResults;

  // A constructor for the class Options which initializes `isScrub` and `fileExtensionWithoutDot`.
  const Options({
    this.isScrub = false,
    this.approveResult = false,
    this.comparator = const CommandLineComparator(),
    this.filesPath,
    this.line,
    this.deleteReceivedFile = false,
    this.namer,
    this.logErrors = true,
    this.logResults = true,
  });

  // A method named `scrub` takes a string input, if `isScrub` is true it scrubs the input,
  // otherwise returns it as is.
  String scrub(String input) => isScrub ? _scrubInput(input) : input;

  // A private method named `_scrubInput` that takes a string as input, removes all extra whitespaces
  // from the string and trims it (removes leading and trailing spaces).
  String _scrubInput(String input) =>
      input.replaceAll(RegExp(r'\s+'), ' ').trim();
}
