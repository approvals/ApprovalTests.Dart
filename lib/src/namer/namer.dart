part of '../../approval_tests.dart';

/// `Namer` class is used to generate the file names for the approved and received files.
final class Namer implements ApprovalNamer {
  final String? filePath;
  final FileNamerOptions? options;
  final bool addTestName;

  const Namer({
    this.filePath,
    this.options,
    this.addTestName = true,
  });

  @override
  String get approved {
    if (options != null) {
      return options!.approved;
    }
    return addTestName
        ? '$filePath.$currentTestName.$approvedExtension'
        : '$filePath.$approvedExtension';
  }

  @override
  String get approvedFileName {
    if (options != null) {
      return options!.approvedFileName;
    }
    return addTestName
        ? '$_fileName.$currentTestName.$approvedExtension'
        : '$_fileName.$approvedExtension';
  }

  @override
  String get received {
    if (options != null) {
      return options!.received;
    }
    return addTestName
        ? '$filePath.$currentTestName.$receivedExtension'
        : '$filePath.$receivedExtension';
  }

  @override
  String get receivedFileName {
    if (options != null) {
      return options!.receivedFileName;
    }
    return addTestName
        ? '$_fileName.$currentTestName.$receivedExtension'
        : '$_fileName.$receivedExtension';
  }

  @override
  String get currentTestName {
    final testName = Invoker.current?.liveTest.individualName;
    return testName == null ? '' : testName.replaceAll(' ', '_');
  }

  String get _fileName => filePath!.split('/').last.split('.dart').first;

  static const String approvedExtension = 'approved.txt';

  static const String receivedExtension = 'received.txt';
}
