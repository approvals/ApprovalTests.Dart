part of '../../approval_tests.dart';

class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  String get filePath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      ApprovalLogger.log(stackTraceString);
      final uriRegExp = RegExp(isWindows ? _windowsPattern : _linuxMacOSPattern);
      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        final rawPath = match.group(1)!;
        final filePath = isWindows ? Uri.file(rawPath, windows: true).toFilePath(windows: true) : Uri.file(rawPath).toFilePath();
        return filePath;
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
  static const String _linuxMacOSPattern = r'file:///([^:\s]+)';
}
