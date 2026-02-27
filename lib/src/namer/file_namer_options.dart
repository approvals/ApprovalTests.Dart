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

/// A class representing options for file naming in approval tests.
///
/// The [FileNamerOptions] class constructs standardized file names for
/// approved and received test outputs, allowing optional descriptions.
final class FileNamerOptions {
  /// The directory where files will be stored.
  final String folderPath;

  /// The base file name.
  final String fileName;

  /// The name of the test associated with the file.
  final String testName;

  /// An optional description to differentiate test outputs.
  final String? description;

  /// Creates a [FileNamerOptions] instance with required parameters.
  const FileNamerOptions({
    required this.folderPath,
    required this.fileName,
    required this.testName,
    this.description,
  });

  /// Returns the full path of the approved file.
  String get approved =>
      '$folderPath${Platform.pathSeparator}$approvedFileName';

  /// Returns the full path of the received file.
  String get received =>
      '$folderPath${Platform.pathSeparator}$receivedFileName';

  /// Generates the approved file name.
  String get approvedFileName => _constructFileName('approved');

  /// Generates the received file name.
  String get receivedFileName => _constructFileName('received');

  /// Constructs a file name based on type and description.
  String _constructFileName(String status) {
    final descPart = description != null ? '.$_updatedDescription' : '';
    return '$fileName.$testName$descPart.$status.txt';
  }

  /// Converts spaces in the description to underscores.
  String get _updatedDescription => description?.replaceAll(' ', '_') ?? '';
}
