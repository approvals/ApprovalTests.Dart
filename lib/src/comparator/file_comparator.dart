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

/// A class `FileComparator` that implements the `Comparator` interface.
/// This class is used to compare the content of two files.
final class FileComparator implements Comparator {
  const FileComparator();

  @override
  bool compare({
    required String approvedPath,
    required String receivedPath,
    bool isLogError = true,
  }) {
    try {
      final approved = _normalizeContent(ApprovalUtils.readFile(approvedPath));
      final received = _normalizeContent(ApprovalUtils.readFile(receivedPath));

      // Return true if contents of both files match exactly
      return approved.compareTo(received) == 0;
    } catch (e, st) {
      if (isLogError) {
        ApprovalLogger.exception("From FileComparator: $e", stackTrace: st);
      }
      rethrow;
    }
  }

  /// Normalizes file content by standardizing line endings.
  String _normalizeContent(String content) =>
      content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}
