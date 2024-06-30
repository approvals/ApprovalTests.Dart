part of '../../approval_tests.dart';

final class FileNamerOptions {
  final String folderPath;
  final String fileName;
  final String testName;
  final String? description;

  const FileNamerOptions({
    required this.folderPath,
    required this.fileName,
    required this.testName,
    required this.description,
  });

  String get approved => '$folderPath/$approvedFileName';

  String get received => '$folderPath/$receivedFileName';

  String get approvedFileName {
    if (description != null) {
      return '$fileName.$testName.$_updatedDescription.approved.txt';
    }
    return '$fileName.$testName.approved.txt';
  }

  String get receivedFileName {
    if (description != null) {
      return '$fileName.$testName.$_updatedDescription.received.txt';
    }
    return '$fileName.$testName.received.txt';
  }

  String get _updatedDescription =>
      description == null ? '' : description!.replaceAll(' ', '_');
}
