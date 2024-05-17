part of '../../approval_tests.dart';

/// A class named `ScrubNothing` that implements the `Scrubber` interface.
/// `ScrubNothing` is default scrubber that does nothing.
class ScrubNothing implements ApprovalScrubber {
  const ScrubNothing();

  @override
  String scrub(String input) => input;
}
