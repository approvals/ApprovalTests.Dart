part of '../../approval_tests.dart';

/// Scrubbers are used to clean up strings before they are compared.
abstract interface class ApprovalScrubber {
  String scrub(String input);
}
