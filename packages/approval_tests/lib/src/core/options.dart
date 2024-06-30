part of '../../approval_tests.dart';

/// `Options` class is a class used to set options for the approval test.
class Options {
  /// `scrubber` is a scrubber that is used to clean up strings before they are compared.
  final ApprovalScrubber scrubber;

  /// A final variable `comparator` of type `Comparator` used to compare the approved and received files.
  final Comparator comparator;

  /// A final variable `reporter` of type `Reporter` used to report the comparison results.
  final Reporter reporter;

  /// A final bool variable `approveResult` used to determine if the result should be approved after the test.
  final bool approveResult;

  /// A final bool variable `deleteReceivedFile` used to determine if the received file should be deleted after passed test.
  final bool deleteReceivedFile;

  /// A final bool variable `deleteApprovedFile` used to determine if the approved file should be deleted after passed test.
  final bool deleteApprovedFile;

  /// A final variable `namer` of type `Namer` used to set the name and path of the file.
  final Namer? namer;

  /// A final bool variable `logErrors` used to determine if the errors should be logged.
  final bool logErrors;

  /// A final bool variable `logResults` used to determine if the results should be logged.
  final bool logResults;

  /// A final bool variable `includeClassNameDuringSerialization` used to determine if the class name should be included during serialization.
  final bool includeClassNameDuringSerialization;

  // A constructor for the class Options which initializes `isScrub` and `fileExtensionWithoutDot`.
  const Options({
    this.scrubber = const ScrubNothing(),
    this.approveResult = false,
    this.comparator = const FileComparator(),
    this.reporter = const CommandLineReporter(),
    this.deleteReceivedFile = true,
    this.deleteApprovedFile = false,
    this.namer,
    this.logErrors = true,
    this.logResults = true,
    this.includeClassNameDuringSerialization = true,
  });

  Options copyWith({
    ApprovalScrubber? scrubber,
    bool? approveResult,
    Comparator? comparator,
    Reporter? reporter,
    bool? deleteReceivedFile,
    bool? deleteApprovedFile,
    Namer? namer,
    bool? logErrors,
    bool? logResults,
    bool? includeClassNameDuringSerialization,
  }) =>
      Options(
        scrubber: scrubber ?? this.scrubber,
        approveResult: approveResult ?? this.approveResult,
        comparator: comparator ?? this.comparator,
        reporter: reporter ?? this.reporter,
        deleteReceivedFile: deleteReceivedFile ?? this.deleteReceivedFile,
        deleteApprovedFile: deleteApprovedFile ?? this.deleteApprovedFile,
        namer: namer ?? this.namer,
        logErrors: logErrors ?? this.logErrors,
        logResults: logResults ?? this.logResults,
        includeClassNameDuringSerialization:
            includeClassNameDuringSerialization ??
                this.includeClassNameDuringSerialization,
      );
}
