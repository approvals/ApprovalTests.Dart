part of '../../approval_tests.dart';

final class FileNamerOptions {
  final String folderPath;
  final String fileName;
  final String testName;

  const FileNamerOptions({
    required this.folderPath,
    required this.fileName,
    required this.testName,
  });

  String get approved => '$folderPath/$approvedFileName';

  String get received => '$folderPath/$receivedFileName';

  String get approvedFileName => '$fileName.$testName.approved.txt';

  String get receivedFileName => '$fileName.$testName.received.txt';
}
