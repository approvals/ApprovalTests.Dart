part of '../approval_test.dart';

/// `ApprovalTestHelper` is a class that provides methods to verify the content of a response. The class is used as an additional layer for ease of testing.
class ApprovalTestHelper {
  const ApprovalTestHelper();

  static const String basePath = 'test/approved_files';

  static const jsonItem = JsonItem(
    id: 1,
    name: "JsonItem",
    anotherItem: AnotherItem(id: 1, name: "AnotherItem"),
    subItem: SubItem(
      id: 1,
      name: "SubItem",
      anotherItems: [
        AnotherItem(id: 1, name: "AnotherItem 1"),
        AnotherItem(id: 2, name: "AnotherItem 2"),
      ],
    ),
  );

  void verify(
    String content,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
    bool useDefaultPath = true,
    ApprovalScrubber scrubber = const ScrubNothing(),
    Reporter reporter = const CommandLineReporter(),
  }) {
    Approvals.verify(
      content,
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
        useDefaultPath: useDefaultPath,
        reporter: reporter,
        scrubber: scrubber,
      ),
    );
  }

  void verifyAll(
    List<dynamic> contents,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
    ApprovalScrubber scrubber = const ScrubNothing(),
    Reporter reporter = const CommandLineReporter(),
  }) {
    Approvals.verifyAll(
      contents,
      processor: (item) => item.toString(), // Simple processor function that returns the item itself.
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
        scrubber: scrubber,
        reporter: reporter,
      ),
    );
  }

  void verifyAsJson(
    dynamic encodable,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
  }) {
    Approvals.verifyAsJson(
      encodable,
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
      ),
    );
  }

  void verifyAllCombinations(
    List<List<int>> combinations,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
  }) {
    Approvals.verifyAllCombinations(
      combinations,
      processor: (combination) => 'Combination: ${combination.join(", ")}',
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
      ),
    );
  }

  void verifySequence(
    List<dynamic> sequence,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
  }) {
    Approvals.verifySequence(
      sequence,
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
      ),
    );
  }

  Future<void> verifyQuery(
    ExecutableQuery query,
    String testName, {
    bool expectException = false,
    bool approveResult = false,
    bool deleteReceivedFile = true,
  }) async {
    await Approvals.verifyQuery(
      query,
      options: _getOptions(
        testName,
        expectException: expectException,
        approveResult: approveResult,
        deleteReceivedFile: deleteReceivedFile,
      ),
    );
  }

  Options _getOptions(
    String testName, {
    required bool expectException,
    required bool approveResult,
    required bool deleteReceivedFile,
    bool useDefaultPath = true,
    ApprovalScrubber scrubber = const ScrubNothing(),
    Reporter reporter = const CommandLineReporter(),
  }) =>
      Options(
        namer: useDefaultPath
            ? Namer(
                options: FileNamerOptions(
                  folderPath: basePath,
                  testName: testName,
                  fileName: 'approval_test',
                ),
              )
            : null,
        deleteReceivedFile: deleteReceivedFile,
        approveResult: approveResult,
        logErrors: !expectException,
        reporter: reporter,
        scrubber: scrubber,
      );

  String get fakeStackTracePath {
    if (Platform.isWindows) {
      return 'file:///C:/path/to/file.dart:10:11\nother stack trace lines...';
    } else {
      return 'file:///path/to/file.dart:10:11\nother stack trace lines...';
    }
  }

  String get testPath {
    if (Platform.isWindows) {
      return 'C:\\path\\to\\file.dart';
    } else {
      return '/path/to/file.dart';
    }
  }
}
