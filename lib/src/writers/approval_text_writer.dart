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

/// Writes text artifacts atomically so readers never observe partial content.
class ApprovalTextWriter extends ApprovalWriter {
  /// Text written after the standard generated-file header.
  final String content;

  /// Creates a writer for [content].
  const ApprovalTextWriter(this.content);

  /// Atomically replaces [path] after flushing a same-directory temporary file.
  ///
  /// Throws [FileSystemException] when the artifact cannot be written or
  /// replaced.
  @override
  void writeToFile(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);

    final temporaryFile = File(
      '$path.$pid.${DateTime.now().microsecondsSinceEpoch}.'
      '${Random.secure().nextInt(0x100000000)}.tmp',
    );

    try {
      temporaryFile.writeAsStringSync(
        '${ApprovalTestsConstants.baseHeader}\n$content',
        flush: true,
      );
      ApprovalFileReplacer().replace(
        replacement: temporaryFile,
        replaced: file,
      );
    } catch (_) {
      try {
        if (temporaryFile.existsSync()) {
          temporaryFile.deleteSync();
        }
      } on FileSystemException catch (error, stackTrace) {
        ApprovalLogger.exception(
          'Failed to clean up a temporary approval file: $error',
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }
}
