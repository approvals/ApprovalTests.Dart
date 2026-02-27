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

part of '../../../approval_tests.dart';

/// Extracts file and directory paths from the current stack trace.
///
/// The [FilePathExtractor] class utilizes an [IStackTraceFetcher] to retrieve
/// stack traces and extract file paths based on platform-specific patterns.
final class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  /// Constructs a [FilePathExtractor] with an optional custom [IStackTraceFetcher].
  /// If no custom fetcher is provided, a default [StackTraceFetcher] is used.
  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  /// Retrieves the file path from the current stack trace.
  ///
  /// This method extracts the first file path found in the stack trace
  /// using platform-specific regular expressions.
  ///
  /// Throws:
  /// - [FileNotFoundException] if no file path is found in the stack trace.
  ///
  /// Returns:
  /// A string representing the extracted file path.
  String get filePath {
    final match = _extractFileMatch();
    if (match == null) {
      throw FileNotFoundException(
        message: 'File not found in stack trace',
        stackTrace: StackTrace.current,
      );
    }

    return isWindows
        ? Uri.file(match.group(1)!, windows: true).toFilePath(windows: true)
        : Uri.parse('file:///${match.group(1)!}').toFilePath();
  }

  /// Retrieves the directory path from the current stack trace.
  ///
  /// This method extracts the file path and determines its parent directory.
  ///
  /// Throws:
  /// - [FileNotFoundException] if no file path is found in the stack trace.
  ///
  /// Returns:
  /// A string representing the extracted directory path.
  String get directoryPath {
    final filePath = this.filePath;
    final separator = isWindows ? '\\' : '/';
    return filePath.substring(0, filePath.lastIndexOf(separator));
  }

  /// Extracts the first matching file path from the stack trace.
  ///
  /// Returns:
  /// A [RegExpMatch] if a match is found, otherwise `null`.
  RegExpMatch? _extractFileMatch() {
    final stackTraceString = _stackTraceFetcher.currentStackTrace;
    final uriRegExp = isWindows ? _windowsRegExp : _linuxMacOSRegExp;
    return uriRegExp.firstMatch(stackTraceString);
  }

  /// Indicates whether the current platform is Windows.
  @visibleForTesting
  static bool isWindows = Platform.isWindows;

  /// Resets [isWindows] to the actual platform value.
  @visibleForTesting
  static void resetPlatform() => isWindows = Platform.isWindows;

  /// Compiled regular expression for extracting file paths on Windows.
  static final RegExp _windowsRegExp = RegExp(r'file:///([a-zA-Z]:/[^:\s]+)');

  /// Compiled regular expression for extracting file paths on Linux and macOS.
  static final RegExp _linuxMacOSRegExp = RegExp(r'file:///([^\s:]+)');
}
