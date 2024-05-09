part of '../../../approval_tests.dart';

/// Extension on [String] to verify the content of a response.
extension ApprovalString on String {
  void verify({
    Options options = const Options(),
  }) {
    Approvals.verify(this, options: options);
  }

  void verifyAsJson({Options options = const Options()}) {
    Approvals.verifyAsJson(this, options: options);
  }
}
