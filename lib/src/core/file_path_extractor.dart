part of '../../approval_tests.dart';

class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  String get filePath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      // ApprovalLogger.log('Stack trace: $stackTraceString');
      //final uriRegExp = RegExp(r'file:\/\/\/([^\s:]+)');
      final uriRegExp = RegExp(r'file://(/[a-zA-Z]:[^\s]*)');
      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        final rawPath = match.group(1)!.replaceAll(RegExp(r':\d+:\d+\)$'), '');
        final filePath = Uri.parse('file://$rawPath');
        return filePath.toFilePath(windows: Platform.isWindows);
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
}
