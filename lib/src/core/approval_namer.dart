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

/// `ApprovalNamer` is an abstract class that defines a contract for generating
/// file names for approved and received files in a test approval process.
///
/// This class provides properties and methods for constructing file paths and
/// names dynamically, considering optional configurations like descriptions,
/// subfolder usage, and test name inclusion.
abstract class ApprovalNamer {
  /// The base file path where the approval and received files will be stored.
  /// Can be `null` if not explicitly set.
  String? get filePath;

  /// Configuration options that influence how file names are generated.
  /// Can be `null` if default behavior is used.
  FileNamerOptions? get options;

  /// Determines whether the test name should be included in the generated file name.
  bool get addTestName;

  /// An optional description to append to the file name for clarity.
  String? get description;

  /// Determines whether files should be placed inside a subfolder.
  bool get useSubfolder;

  /// The full path of the approved file.
  String get approved;

  /// The generated file name for the approved file.
  String get approvedFileName;

  /// The full path of the received file.
  String get received;

  /// The generated file name for the received file.
  String get receivedFileName;

  /// Retrieves the current test name to be used in naming the files.
  String get currentTestName;

  /// Creates a copy of the current `ApprovalNamer` instance with overridden properties.
  ///
  /// This allows modifications without mutating the original instance, following
  /// the immutability principle.
  ///
  /// - [filePath]: Overrides the base file path.
  /// - [options]: Overrides the file naming options.
  /// - [addTestName]: Changes whether the test name should be included.
  /// - [description]: Modifies the optional description.
  /// - [useSubfolder]: Determines whether subfolder usage is enabled.
  ApprovalNamer copyWith({
    String? filePath,
    FileNamerOptions? options,
    bool? addTestName,
    String? description,
    bool? useSubfolder,
  });
}

/// Base class for file name generation in approval tests.
///
/// This class centralizes the common logic used by [Namer] and [IndexedNamer].
abstract class BaseNamer implements ApprovalNamer {
  @override
  final String? filePath;
  @override
  final FileNamerOptions? options;
  @override
  final bool addTestName;
  @override
  final String? description;
  @override
  final bool useSubfolder;

  /// Constructor for the base namer.
  const BaseNamer({
    this.filePath,
    this.options,
    this.addTestName = true,
    this.description,
    this.useSubfolder = false,
  });

  /// Retrieves the current test name formatted for file naming.
  @override
  String get currentTestName {
    final testName = Invoker.current?.liveTest.individualName;
    return testName?.replaceAll(' ', '_').toLowerCase() ?? '';
  }

  /// Returns a formatted version of the description, replacing spaces with underscores.
  String get _formattedDescription =>
      description?.replaceAll(' ', '_').toLowerCase() ?? '';

  /// Builds the full file path including the test name, description, and optional counter.
  String _buildFilePath(String extension, {String counter = ''}) {
    final base = _basePath;
    final testNamePart = addTestName ? '.$currentTestName' : '';
    final descriptionPart =
        description != null ? '.$_formattedDescription' : '';
    final counterPart = counter.isNotEmpty ? '.$counter' : '';
    return '$base$testNamePart$descriptionPart$counterPart.$extension';
  }

  /// Constructs the file name without the full directory path.
  String _buildFileName(String extension, {String counter = ''}) {
    final name = _fileName;
    final testNamePart = addTestName ? '.$currentTestName' : '';
    final descriptionPart =
        description != null ? '.$_formattedDescription' : '';
    final counterPart = counter.isNotEmpty ? '.$counter' : '';
    return '$name$testNamePart$descriptionPart$counterPart.$extension';
  }

  /// Computes the base file path without the extension.
  ///
  /// If [useSubfolder] is true, the files will be placed inside an `approvals` subdirectory.
  String get _basePath {
    final separator = Platform.pathSeparator;
    final directory = filePath!.substring(0, filePath!.lastIndexOf(separator));
    final fileName = filePath!.split(separator).last.split('.dart').first;
    final baseDir =
        useSubfolder ? '$directory${separator}approvals' : directory;
    return '$baseDir$separator$fileName';
  }

  /// Extracts the file name without the directory path.
  String get _fileName =>
      filePath!.split(Platform.pathSeparator).last.split('.dart').first;

  /// Constants defining file extensions used for approval testing.
  static const String approvedExtension = 'approved.txt';
  static const String receivedExtension = 'received.txt';
}
