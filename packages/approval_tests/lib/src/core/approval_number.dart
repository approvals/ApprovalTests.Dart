part of '../../approval_tests.dart';

/// `ApprovalNamer` is an abstract class that provides methods to generate the file names for the approved and received files.
abstract interface class ApprovalNamer {
  /// A getter named `approved` that returns the string `'file_name.test_name.approved.txt'`.
  String get approved;

  /// A getter named `received` that returns the string `'file_name.test_name.received.txt'`.
  String get received;

  /// A getter named `approvedFileName` that returns the string `'file_name.approved.txt'`.
  String get approvedFileName;

  /// A getter named `receivedFileName` that returns the string `'file_name.received.txt'`.
  String get receivedFileName;

  /// A getter named `currentTestName` that returns the current test name.
  String get currentTestName;
}
