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
  static Future<void> verify(
    String response, {
    Options options = const Options(),
  }) async {
    // Get the file path without extension or use the provided file path
    final completedPath = options.namer.filePath ??
        ApprovalUtils.removeFileExtension(
          filePathExtractor.filePath,
          extension: '.dart',
        );

    // Create namer object with given or computed file name
    final namer = options.namer.copyWith(
      filePath: completedPath,
    );

    try {
      // Create writer object with scrubbed response and file extension retrieved from options
      final writer = ApprovalTextWriter(
        options.scrubber.scrub(response),
      );

      // Write the content to a file whose path is specified in namer.received
      writer.writeToFile(namer.received);

      if (options.approveResult ||
          !ApprovalUtils.isFileExists(namer.approved)) {
        writer.writeToFile(namer.approved);
      }

      // Check if received file matches the approved file
      final bool isFilesMatch = options.comparator.compare(
        approvedPath: namer.approved,
        receivedPath: namer.received,
        isLogError: options.logErrors,
      );

      // Log results and throw exception if files do not match
      if (!isFilesMatch) {
        await options.reporter.report(namer.approved, namer.received);
        throw DoesntMatchException(
          'Oops: [${namer.approvedFileName}] does not match [${namer.receivedFileName}].\n\n - Approved file path: ${namer.approved}\n\n - Received file path: ${namer.received}',
        );
      }

      if (options.logResults) {
        ApprovalLogger.success(
          'Test passed: [${namer.approvedFileName}] matches [${namer.receivedFileName}]\n\n- Approved file path: ${namer.approved}\n\n- Received file path: ${namer.received}',
        );
      }

      if (options.deleteReceivedFile) {
        _deleteFileAfterTest(namer: namer, fileType: FileType.received);
      }
    } catch (e, st) {
      if (options.logErrors) {
        ApprovalLogger.exception(e, stackTrace: st);
      }
      rethrow;
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

  @visibleForTesting
  static Map<FileType, String Function(ApprovalNamer)> fileToNamerMap = {
    FileType.approved: (ApprovalNamer n) => n.approved,
    FileType.received: (ApprovalNamer n) => n.received,
  };

  /// Verifies all combinations of inputs for a provided function.
  static Future<void> verifyAll<T>(
    List<T> inputs, {
    required String Function(T item) processor,
    Options options = const Options(),
  }) async {
    try {
      // Process the combination to get the response
      final response = inputs.map((e) => processor(e));

      final responseString = response.join('\n');

      // Verify the processed response
      await verify(responseString, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // Method to encode object to JSON and then verify it
  static Future<void> verifyAsJson(
    dynamic encodable, {
    Options options = const Options(),
  }) async {
    try {
      // Encode the object into JSON format
      final jsonContent = ApprovalConverter.encodeReflectively(
        encodable,
        includeClassName: options.includeClassNameDuringSerialization,
      );
      final prettyJson = ApprovalConverter.convert(jsonContent);

      // Call the verify method on encoded JSON content
      await verify(prettyJson, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // Method to convert a sequence of objects to string format and then verify it
  static Future<void> verifySequence(
    List<dynamic> sequence, {
    Options options = const Options(),
  }) async {
    try {
      // Convert the sequence of objects into a multiline string
      final content = sequence.map((e) => e.toString()).join('\n');

      // Call the verify method on this content
      await verify(content, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // Method to verify executable queries
  static Future<void> verifyQuery(
    ExecutableQuery query, {
    Options options = const Options(),
  }) async {
    try {
      // Get the query string from the ExecutableQuery instance
      final queryString = query.getQuery();

      // Write and possibly execute the query, then verify the result
      final resultString = await query.executeQuery(queryString);

      // Use the existing verify method to check the result against approved content
      await verify(resultString, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // ================== Combinations ==================

  /// Verifies all combinations of inputs for a provided function.
  static Future<void> verifyAllCombinations<T>(
    List<List<T>> inputs, {
    required String Function(Iterable<List<T>> combination) processor,
    Options options = const Options(),
  }) async {
    // Generate all combinations of inputs
    final combinations = ApprovalUtils.cartesianProduct(inputs);

    // Iterate over each combination, apply the processor function, and verify the result

    try {
      // Process the combination to get the response
      final response = processor(combinations);

      // Verify the processed response
      await verify(response, options: options);
    } catch (_) {
      rethrow;
    }
  }
}
