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

part of '../approval_tests.dart';

/// `Approvals` is a class that provides methods to verify the content of a response.
class Approvals {
  static const FilePathExtractor filePathExtractor =
      FilePathExtractor(stackTraceFetcher: StackTraceFetcher());

  // ================== Verify methods ==================

  // Method to verify if the content in response matches the approved content
  static void verify(
    String response, {
    Options options = const Options(),
  }) {
    final namer = _resolveNamer(options);

    try {
      _writeApprovalFiles(response, namer, options);
      _compareAndReport(namer, options);
      _logSuccessAndCleanup(namer, options);
    } catch (e, st) {
      if (options.logErrors && e is! DoesntMatchException) {
        ApprovalLogger.exception(e, stackTrace: st);
      }
      rethrow;
    }
  }

  static ApprovalNamer _resolveNamer(Options options) {
    final completedPath = options.namer.filePath ??
        ApprovalUtils.removeFileExtension(
          filePathExtractor.filePath,
          extension: '.dart',
        );

    return options.namer.copyWith(
      filePath: completedPath,
    );
  }

  static void _writeApprovalFiles(
    String response,
    ApprovalNamer namer,
    Options options,
  ) {
    final writer = ApprovalTextWriter(
      options.scrubber.scrub(response),
    );

    writer.writeToFile(namer.received);

    if (options.approveResult ||
        !ApprovalUtils.isFileExists(namer.approved)) {
      writer.writeToFile(namer.approved);
    }
  }

  static void _compareAndReport(ApprovalNamer namer, Options options) {
    final bool isFilesMatch = options.comparator.compare(
      approvedPath: namer.approved,
      receivedPath: namer.received,
      isLogError: options.logErrors,
    );

    if (!isFilesMatch) {
      unawaited(
        options.reporter
            .report(namer.approved, namer.received)
            .catchError((Object e, StackTrace st) {
          ApprovalLogger.exception('Reporter failed: $e', stackTrace: st);
        }),
      );
      throw DoesntMatchException(
        'Oops: [${namer.approvedFileName}] does not match [${namer.receivedFileName}].\n\n - Approved file path: ${namer.approved}\n\n - Received file path: ${namer.received}',
      );
    }
  }

  static void _logSuccessAndCleanup(ApprovalNamer namer, Options options) {
    if (options.logResults) {
      ApprovalLogger.success(
        'Test passed: [${namer.approvedFileName}] matches [${namer.receivedFileName}]\n\n- Approved file path: ${namer.approved}\n\n- Received file path: ${namer.received}',
      );
    }

    if (options.deleteReceivedFile) {
      _deleteFileAfterTest(namer: namer, fileType: FileType.received);
    }
  }

  /// `_deleteFileAfterTest` method to delete the received file after the test.
  static void _deleteFileAfterTest({
    required ApprovalNamer? namer,
    required FileType fileType,
  }) {
    final resolvedPath = filePathForDeletion(
      namer: namer,
      fileType: fileType,
    );
    ApprovalUtils.deleteFile(resolvedPath);
  }

  @visibleForTesting
  static String filePathForDeletion({
    required ApprovalNamer? namer,
    required FileType fileType,
  }) {
    final filePathResolver = fileToNamerMap[fileType];
    if (filePathResolver == null) {
      throw ArgumentError.value(
        fileType,
        'fileType',
        'Unsupported file type for deletion',
      );
    }
    final resolvedNamer = namer ??
        Namer(
          filePath: ApprovalUtils.removeFileExtension(
            filePathExtractor.filePath,
            extension: '.dart',
          ),
        );
    return filePathResolver(resolvedNamer);
  }

  static const Map<FileType, String Function(ApprovalNamer)>
      _defaultFileToNamerMap = {
    FileType.approved: _approvedPath,
    FileType.received: _receivedPath,
  };

  static String _approvedPath(ApprovalNamer n) => n.approved;
  static String _receivedPath(ApprovalNamer n) => n.received;

  @visibleForTesting
  static Map<FileType, String Function(ApprovalNamer)> fileToNamerMap =
      Map<FileType, String Function(ApprovalNamer)>.from(
    _defaultFileToNamerMap,
  );

  @visibleForTesting
  static void resetFileToNamerMap() {
    fileToNamerMap = Map<FileType, String Function(ApprovalNamer)>.from(
      _defaultFileToNamerMap,
    );
  }

  /// Verifies all combinations of inputs for a provided function.
  static void verifyAll<T>(
    List<T> inputs, {
    required String Function(T item) processor,
    Options options = const Options(),
  }) {
    final response = inputs.map((e) => processor(e));
    final responseString = response.join('\n');
    verify(responseString, options: options);
  }

  // Method to encode object to JSON and then verify it
  static void verifyAsJson(
    dynamic encodable, {
    Options options = const Options(),
  }) {
    final prettyJson = ApprovalConverter.convertObject(
      encodable,
      includeClassName: options.includeClassNameDuringSerialization,
    );
    verify(prettyJson, options: options);
  }

  // Method to convert a sequence of objects to string format and then verify it
  static void verifySequence(
    List<dynamic> sequence, {
    Options options = const Options(),
  }) {
    final content = sequence.map((e) => e.toString()).join('\n');
    verify(content, options: options);
  }

  // Method to verify executable queries
  static Future<void> verifyQuery(
    ExecutableQuery query, {
    Options options = const Options(),
  }) async {
    final queryString = query.getQuery();
    final resultString = await query.executeQuery(queryString);
    verify(resultString, options: options);
  }

  // ================== Combinations ==================

  /// Verifies all combinations of inputs for a provided function.
  static void verifyAllCombinations<T>(
    List<List<T>> inputs, {
    required String Function(Iterable<List<T>> combination) processor,
    Options options = const Options(),
  }) {
    final combinations = ApprovalUtils.cartesianProduct(inputs);
    final response = processor(combinations);
    verify(response, options: options);
  }
}
