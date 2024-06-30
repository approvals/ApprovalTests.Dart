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

part of '../../../approval_tests.dart';

class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  String get filePath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      final uriRegExp =
          RegExp(isWindows ? _windowsPattern : _linuxMacOSPattern);
      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        if (isWindows) {
          final rawPath = match.group(1)!;
          final filePath =
              Uri.file(rawPath, windows: true).toFilePath(windows: true);
          return filePath;
        } else {
          final filePath = Uri.tryParse('file:///${match.group(1)!}');
          return filePath!.toFilePath();
        }
      } else {
        throw FileNotFoundException(
          message: 'File not found in stack trace',
          stackTrace: StackTrace.current,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  String get directoryPath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      final uriRegExp =
          RegExp(isWindows ? _windowsPattern : _linuxMacOSPattern);
      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        String filePath;
        if (isWindows) {
          final rawPath = match.group(1)!;
          filePath = Uri.file(rawPath, windows: true).toFilePath(windows: true);
        } else {
          filePath = Uri.tryParse('file:///${match.group(1)!}')!.toFilePath();
        }

        final directoryPath = filePath.substring(0, filePath.lastIndexOf('/'));
        return directoryPath;
      } else {
        throw FileNotFoundException(
          message: 'File not found in stack trace',
          stackTrace: StackTrace.current,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static bool isWindows = Platform.isWindows;

  static const String _windowsPattern = r'file:///([a-zA-Z]:/[^:\s]+)';
  static const String _linuxMacOSPattern = r'file:\/\/\/([^\s:]+)';
}
