part of '../../../approval_tests.dart';

class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  String get filePath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      final uriRegExp = RegExp(isWindows ? _windowsPattern : _linuxMacOSPattern);
      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        if (isWindows) {
          final rawPath = match.group(1)!;
          final filePath = Uri.file(rawPath, windows: true).toFilePath(windows: true);
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
      final uriRegExp = RegExp(isWindows ? _windowsPattern : _linuxMacOSPattern);
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
