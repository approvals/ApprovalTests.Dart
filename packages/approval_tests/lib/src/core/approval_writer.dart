part of '../../approval_tests.dart';

/// `ApprovalWriter` is an abstract class for writing approvals.
abstract interface class ApprovalWriter {
  /// A method named `approvalFilename` that returns name of approved file.
  String approvalFilename(String base);

  /// A method named `receivedFilename` that returns name of received file.
  String receivedFilename(String base);

  /// `writeReceivedFile` method writes the received file.
  void writeReceivedFile(String received);
}
