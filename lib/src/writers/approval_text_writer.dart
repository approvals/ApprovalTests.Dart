/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

part of '../../approval_tests.dart';

/// `ApprovalTextWriter` is a class that writes the content to a file at the specified path.
class ApprovalTextWriter extends ApprovalWriter {
  // The two instance variables content and fileExtension of type String
  final String content;

  // Constructor for the class ApprovalTextWriter that takes in two parameters: content and fileExtension
  const ApprovalTextWriter(this.content);

  // A method that writes the given content to the file at the specified path
  @override
  void writeToFile(String path) {
    final File file = File(path);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync('${ApprovalTestsConstants.baseHeader}\n$content');
  }
}
