part of '../../approval_tests.dart';

/// `Comparator` is an abstract class for comparing files.
abstract interface class Comparator {
  /// A method named `compare` for comparing two files.
  bool compare({
    required String approvedPath,
    required String receivedPath,
    bool isLogError = true,
  });
}
