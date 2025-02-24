/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

part of '../../approval_tests.dart';

/// A utility class responsible for generating structured file names
/// for approval testing, ensuring consistency across test runs.
final class Namer implements ApprovalNamer {
  final String? filePath;
  final FileNamerOptions? options;
  final bool addTestName;
  final String? description;
  final bool useSubfolder;

  /// Creates a [Namer] instance with customizable file naming parameters.
  ///
  /// - [filePath]: The base file path for generated names.
  /// - [options]: If provided, overrides default naming logic.
  /// - [addTestName]: Whether to include the test name in the file name.
  /// - [description]: An optional description to differentiate test cases.
  /// - [useSubfolder]: Whether to store files in an `approvals` subdirectory.
  const Namer({
    this.filePath,
    this.options,
    this.addTestName = true,
    this.description,
    this.useSubfolder = false,
  });

  /// Returns the fully qualified approved file path.
  @override
  String get approved => options?.approved ?? _buildFilePath(approvedExtension);

  /// Returns the generated approved file name.
  @override
  String get approvedFileName =>
      options?.approvedFileName ?? _buildFileName(approvedExtension);

  /// Returns the fully qualified received file path.
  @override
  String get received => options?.received ?? _buildFilePath(receivedExtension);

  /// Returns the generated received file name.
  @override
  String get receivedFileName =>
      options?.receivedFileName ?? _buildFileName(receivedExtension);

  /// Retrieves the current test name, formatted appropriately.
  @override
  String get currentTestName {
    final testName = Invoker.current?.liveTest.individualName;
    return testName?.replaceAll(' ', '_').toLowerCase() ?? '';
  }

  /// Returns a formatted version of the description, replacing spaces with underscores.
  String get _formattedDescription =>
      description?.replaceAll(' ', '_').toLowerCase() ?? '';

  /// Constructs a full file path, including directory and extension.
  String _buildFilePath(String extension) {
    final base = _basePath;
    final testNamePart = addTestName ? '.$currentTestName' : '';
    final descriptionPart =
        description != null ? '.$_formattedDescription' : '';
    return '$base$testNamePart$descriptionPart.$extension';
  }

  /// Constructs only the file name portion, without the directory path.
  String _buildFileName(String extension) {
    final name = _fileName;
    final testNamePart = addTestName ? '.$currentTestName' : '';
    final descriptionPart =
        description != null ? '.$_formattedDescription' : '';
    return '$name$testNamePart$descriptionPart.$extension';
  }

  /// Computes the base file path without its extension.
  /// If [useSubfolder] is true, the file will be placed inside an `approvals` subfolder.
  String get _basePath {
    final separator = Platform.pathSeparator;
    final directory = filePath!.substring(0, filePath!.lastIndexOf(separator));
    final fileName = filePath!.split(separator).last.split('.dart').first;
    final baseDir =
        useSubfolder ? '$directory${separator}approvals' : directory;
    return '$baseDir$separator$fileName';
  }

  /// Extracts the file name without its directory path.
  String get _fileName =>
      filePath!.split(Platform.pathSeparator).last.split('.dart').first;

  /// Constants defining the file extensions used for approval testing.
  static const String approvedExtension = 'approved.txt';
  static const String receivedExtension = 'received.txt';

  /// Creates a modified copy of the current [Namer] instance with new values.
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
