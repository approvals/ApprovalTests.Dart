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

/// A standard file namer without indexing.
///
/// The [Namer] class extends [BaseNamer] and provides functionality
/// to generate approved and received file names and paths based on
/// customizable options.
final class Namer extends BaseNamer {
  /// Creates a [Namer] instance with customizable file naming parameters.
  ///
  /// - [filePath]: The base file path where files will be saved.
  /// - [options]: An optional configuration for custom file names and paths.
  /// - [addTestName]: Determines whether to append the test name to the file.
  /// - [description]: An optional description appended to the file name.
  /// - [useSubfolder]: Whether to store files inside a dedicated subfolder.
  const Namer({
    super.filePath,
    super.options,
    super.addTestName,
    super.description,
    super.useSubfolder,
  });

  /// Returns the fully qualified file path for the approved file.
  ///
  /// Uses the custom path from [options] if provided; otherwise, generates
  /// a default file path with the [BaseNamer.approvedExtension].
  @override
  String get approved =>
      options?.approved ?? _buildFilePath(BaseNamer.approvedExtension);

  /// Returns the file name for the approved file.
  ///
  /// Uses the custom file name from [options] if provided; otherwise, generates
  /// a default file name with the [BaseNamer.approvedExtension].
  @override
  String get approvedFileName =>
      options?.approvedFileName ?? _buildFileName(BaseNamer.approvedExtension);

  /// Returns the fully qualified file path for the received file.
  ///
  /// Uses the custom path from [options] if provided; otherwise, generates
  /// a default file path with the [BaseNamer.receivedExtension].
  @override
  String get received =>
      options?.received ?? _buildFilePath(BaseNamer.receivedExtension);

  /// Returns the file name for the received file.
  ///
  /// Uses the custom file name from [options] if provided; otherwise, generates
  /// a default file name with the [BaseNamer.receivedExtension].
  @override
  String get receivedFileName =>
      options?.receivedFileName ?? _buildFileName(BaseNamer.receivedExtension);

  /// Creates a new [Namer] instance with updated values while preserving
  /// existing values when parameters are not provided.
  ///
  /// - [filePath]: New base file path, if provided.
  /// - [options]: New configuration for file naming, if provided.
  /// - [addTestName]: Whether to append the test name to the file.
  /// - [description]: A new description appended to the file name.
  /// - [useSubfolder]: Whether to use a dedicated subfolder.
  ///
  /// Returns a new [Namer] instance with updated values.
  @override
  Namer copyWith({
    String? filePath,
    FileNamerOptions? options,
    bool? addTestName,
    String? description,
    bool? useSubfolder,
  }) {
    return Namer(
      filePath: filePath ?? this.filePath,
      options: options ?? this.options,
      addTestName: addTestName ?? this.addTestName,
      description: description ?? this.description,
      useSubfolder: useSubfolder ?? this.useSubfolder,
    );
  }
}
