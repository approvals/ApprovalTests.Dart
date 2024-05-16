part of '../../approval_tests.dart';

/// `Namer` class is used to generate the file names for the approved and received files.
final class Namer implements ApprovalNamer {
  final String file;

  const Namer(this.file);

  @override
  String get approved => '$file.$currentTestName.approved.txt';

  @override
  String get approvedFileName => '${file.split('/').last.split('.dart').first}.approved.txt';

  @override
  String get received => '$file.$currentTestName.received.txt';

  @override
  String get receivedFileName => '${file.split('/').last.split('.dart').first}.received.txt';

  @override
  String get currentTestName {
    final testName = Invoker.current?.liveTest.individualName;
    return testName == null ? '' : testName.replaceAll(' ', '_');
  }
}
