part of '../../approval_tests.dart';

/// `Reporter` is an abstract class for reporting the comparison results.
abstract interface class Reporter {
  void report(String approvedPath, String receivedPath);
}
