part of '../../approval_tests.dart';

class FilePathExtractor {
  final IStackTraceFetcher _stackTraceFetcher;

  const FilePathExtractor({
    IStackTraceFetcher? stackTraceFetcher,
  }) : _stackTraceFetcher = stackTraceFetcher ?? const StackTraceFetcher();

  String get filePath {
    try {
      final stackTraceString = _stackTraceFetcher.currentStackTrace;
      final uriRegExp = RegExp(r'file:\/\/\/([^\s:]+)');

      final match = uriRegExp.firstMatch(stackTraceString);

      if (match != null) {
        final filePath = Uri.tryParse('file:///${match.group(1)!}');
        return filePath!.toFilePath();
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
