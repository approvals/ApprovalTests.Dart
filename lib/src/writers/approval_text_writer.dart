part of '../../approval_tests.dart';

/// `ApprovalTextWriter` is a class that writes the content to a file at the specified path.
class ApprovalTextWriter {
  // The two instance variables content and fileExtension of type String
  final String content;
  final String fileExtension;

  // Constructor for the class ApprovalTextWriter that takes in two parameters: content and fileExtension
  const ApprovalTextWriter(this.content, this.fileExtension);

  // A method that writes the given content to the file at the specified path
  void writeToFile(String path) {
    // File instance is created with the given path
    final File file = File(path);

    // Check if the file already exists at the specific path
    if (!file.existsSync()) {
      // If the file does not exist, then it is created
      file.createSync(recursive: true);

      // After creating the file, the content is written to it
      file.writeAsStringSync(content);
    } else {
      // If the file already exists, then the content is simply overwritten
      file.writeAsStringSync(content);
    }
  }
}
