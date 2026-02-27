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

/// A file namer that automatically increments an index for unique file names.
///
/// The [IndexedNamer] class extends [BaseNamer] and ensures that each test
/// generates unique approved and received file names by maintaining an
/// auto-incrementing counter.
final class IndexedNamer extends BaseNamer {
  /// Auto-incrementing counter for ensuring unique file names.
  final int counter;

  /// Stores the count of approvals for each test name to ensure unique names.
  static final Map<String, int> _approvalCounts = {};

  /// Clears the internal counter state. Useful for resetting between tests.
  @visibleForTesting
  static void resetCounters() => _approvalCounts.clear();

  /// Creates an [IndexedNamer] instance with an incremented counter.
  ///
  /// - [filePath]: The base file path where files will be saved.
  /// - [options]: Optional configuration for file naming.
  /// - [addTestName]: Whether to append the test name to the file.
  /// - [description]: An optional description appended to the file name.
  /// - [useSubfolder]: Whether to store files inside a dedicated subfolder.
  /// - [counter]: A manually provided counter value (optional, defaults to auto-generated).
  IndexedNamer({
    super.filePath,
    super.options,
    super.addTestName,
    super.description,
    super.useSubfolder,
    int? counter, // Allows manual counter override.
  }) : counter = counter ?? _getNextCounter(filePath);

  /// Retrieves the next available counter value for a given file path.
  ///
  /// Uses the [Invoker] to determine the test name, ensuring each test
  /// maintains a unique counter.
  ///
  /// - [filePath]: The file path for which the counter should be generated.
  /// - Returns: An incremented counter value.
  static int _getNextCounter(String? filePath) {
    final testName =
        BaseNamer.formatTestName(Invoker.current?.liveTest.individualName);
    final key = '$filePath-$testName';

    return _approvalCounts.update(key, (value) => value + 1, ifAbsent: () => 0);
  }

  /// Returns the fully qualified approved file path with an index.
  ///
  /// Uses the custom path from [options] if provided; otherwise, generates
  /// a default file path with the [BaseNamer.approvedExtension] and appends
  /// an auto-incremented counter to ensure uniqueness.
  @override
  String get approved =>
      options?.approved ??
      _buildFilePath(BaseNamer.approvedExtension, counter: '$counter');

  /// Returns the generated approved file name with an index.
  ///
  /// Uses the custom file name from [options] if provided; otherwise, generates
  /// a default file name with the [BaseNamer.approvedExtension] and appends
  /// an auto-incremented counter.
  @override
  String get approvedFileName =>
      options?.approvedFileName ??
      _buildFileName(BaseNamer.approvedExtension, counter: '$counter');

  /// Returns the fully qualified received file path with an index.
  ///
  /// Uses the custom path from [options] if provided; otherwise, generates
  /// a default file path with the [BaseNamer.receivedExtension] and appends
  /// an auto-incremented counter.
  @override
  String get received =>
      options?.received ??
      _buildFilePath(BaseNamer.receivedExtension, counter: '$counter');

  /// Returns the generated received file name with an index.
  ///
  /// Uses the custom file name from [options] if provided; otherwise, generates
  /// a default file name with the [BaseNamer.receivedExtension] and appends
  /// an auto-incremented counter.
  @override
  String get receivedFileName =>
      options?.receivedFileName ??
      _buildFileName(BaseNamer.receivedExtension, counter: '$counter');

  /// Creates a modified copy of the current [IndexedNamer] instance with updated values.
  ///
  /// This method allows modifications to properties while keeping existing
  /// values when parameters are not provided.
  ///
  /// - [filePath]: New base file path, if provided.
  /// - [options]: New configuration for file naming, if provided.
  /// - [addTestName]: Whether to append the test name to the file.
  /// - [description]: A new description appended to the file name.
  /// - [useSubfolder]: Whether to use a dedicated subfolder.
  /// - [counter]: A manually provided counter value.
  ///
  /// Returns a new [IndexedNamer] instance with the updated values.
  @override
  IndexedNamer copyWith({
    String? filePath,
    FileNamerOptions? options,
    bool? addTestName,
    String? description,
    bool? useSubfolder,
    int? counter,
  }) {
    return IndexedNamer(
      filePath: filePath ?? this.filePath,
      options: options ?? this.options,
      addTestName: addTestName ?? this.addTestName,
      description: description ?? this.description,
      useSubfolder: useSubfolder ?? this.useSubfolder,
      counter: counter ?? this.counter, // Ensuring counter is preserved.
    );
  }
}
