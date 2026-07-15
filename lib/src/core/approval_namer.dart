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

final class _ApprovalName {
  static const int maxSegmentBytes = 255;

  static final RegExp _invalidCharacters = RegExp(
    r'''[<>:"|?*\x00-\x1F\x7F]''',
  );
  static final RegExp _trailingDotsAndSpaces = RegExp(r'[ .]+$');
  static final RegExp _reservedName = RegExp(
    r'^(?:con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)',
    caseSensitive: false,
  );

  static String normalizeSegment(
    String value, {
    required String component,
  }) {
    if (value.contains('/') || value.contains(r'\')) {
      throw InvalidApprovalNameException(
        component: component,
        value: value,
        reason: 'path separators are not allowed in filename segments',
      );
    }

    var normalized = value.replaceAll(_invalidCharacters, '_');
    normalized = normalized.replaceAllMapped(
      _trailingDotsAndSpaces,
      (match) => List.filled(match[0]!.length, '_').join(),
    );

    if (_reservedName.hasMatch(normalized)) {
      normalized = '_$normalized';
    }

    return normalized;
  }

  static String buildFileName({
    required String stem,
    required String extension,
  }) {
    final normalizedExtension = normalizeSegment(
      extension,
      component: 'extension',
    );
    final fileName = '$stem.$normalizedExtension';
    if (utf8.encode(fileName).length <= maxSegmentBytes) {
      return fileName;
    }

    final hash = _stableHash(fileName);
    final suffix = '.$hash.$normalizedExtension';
    final prefixBudget = maxSegmentBytes - utf8.encode(suffix).length;
    var prefix = _truncateUtf8(stem, prefixBudget);
    prefix = prefix.replaceFirst(RegExp(r'[ .]+$'), '');
    return '$prefix$suffix';
  }

  static void validateArtifactPath(
    String path, {
    required String component,
  }) {
    final segment = p.basename(path);
    final normalized = normalizeSegment(segment, component: component);
    if (normalized != segment) {
      throw InvalidApprovalNameException(
        component: component,
        value: segment,
        reason: 'artifact filename contains characters that require '
            'normalization',
      );
    }
    if (utf8.encode(segment).length > maxSegmentBytes) {
      throw InvalidApprovalNameException(
        component: component,
        value: segment,
        reason: 'artifact filename exceeds $maxSegmentBytes UTF-8 bytes',
      );
    }
  }

  static String _stableHash(String value) {
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static String _truncateUtf8(String value, int maxBytes) {
    final result = StringBuffer();
    var byteCount = 0;
    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final characterBytes = utf8.encode(character).length;
      if (byteCount + characterBytes > maxBytes) {
        break;
      }
      result.write(character);
      byteCount += characterBytes;
    }
    return result.toString();
  }
}

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

  /// Formats a raw test name for use in file paths by replacing spaces
  /// with underscores and converting to lowercase.
  static String formatTestName(String? name) {
    final normalized = _ApprovalName.normalizeSegment(
      name?.toLowerCase() ?? '',
      component: 'test name',
    );
    return normalized.replaceAll(' ', '_');
  }

  /// Retrieves the current test name formatted for file naming.
  @override
  String get currentTestName =>
      formatTestName(Invoker.current?.liveTest.individualName);

  String get _formattedDescription {
    final normalized = _ApprovalName.normalizeSegment(
      description?.toLowerCase() ?? '',
      component: 'description',
    );
    return normalized.replaceAll(' ', '_');
  }

  String _buildName(String base, String extension, {String counter = ''}) {
    final testNameValue = currentTestName;
    final hasTestName = addTestName && testNameValue.isNotEmpty;
    final testNamePart = hasTestName ? '.$testNameValue' : '';
    final descriptionValue = _formattedDescription;
    final hasDescription = description != null && descriptionValue.isNotEmpty;
    final descriptionPart = hasDescription ? '.$descriptionValue' : '';
    final counterPart = counter.isNotEmpty ? '.$counter' : '';
    return _ApprovalName.buildFileName(
      stem: '$base$testNamePart$descriptionPart$counterPart',
      extension: extension,
    );
  }

  String _buildFilePath(String extension, {String counter = ''}) {
    final basePath = _basePath;
    return p.join(
      p.dirname(basePath),
      _buildName(p.basename(basePath), extension, counter: counter),
    );
  }

  String _buildFileName(String extension, {String counter = ''}) =>
      _buildName(_fileName, extension, counter: counter);

  String get _basePath {
    final directory = p.dirname(filePath!);
    final baseDir = useSubfolder ? p.join(directory, 'approvals') : directory;
    return p.join(baseDir, _fileName);
  }

  String get _fileName => _ApprovalName.normalizeSegment(
        p.basenameWithoutExtension(filePath!),
        component: 'file name',
      );

  static const String approvedExtension = 'approved.txt';
  static const String receivedExtension = 'received.txt';
}
