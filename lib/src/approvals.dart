part of '../approval_tests.dart';

/// `Approvals` is a class that provides methods to verify the content of a response.
class Approvals {
  // Factory method to create an instance of ApprovalNamer with given file name
  static ApprovalNamer makeNamer(String file) => Namer(file);

  // ================== Verify methods ==================

  // Method to verify if the content in response matches the approved content
  static void verify(
    String response, {
    Options options = const Options(),
  }) {
    try {
      // Get the file path without extension or use the provided file path
      final completedPath =
          options.filesPath ?? ApprovalUtils.filePath.split('.').first;

      // Create namer object with given or computed file name
      final namer = makeNamer(options.filesPath ?? completedPath);

      // Create writer object with scrubbed response and file extension retrieved from options
      final writer = ApprovalTextWriter(options.scrub(response), "txt");

      // Write the content to a file whose path is specified in namer.received
      writer.writeToFile(namer.received);

      if (options.approveResult) {
        writer.writeToFile(namer.approved);
      }

      // Check if received file matches the approved file
      final bool isFilesMatch =
          ApprovalUtils.filesMatch(namer.approved, namer.received);

      // Log results and throw exception if files do not match
      if (!isFilesMatch) {
        options.comparator.compare(
          approvedPath: namer.approved,
          receivedPath: namer.received,
          isLogError: options.logErrors,
        );
        throw DoesntMatchException(
          'Test failed: ${namer.approved} does not match ${namer.received}',
        );
      } else if (isFilesMatch) {
        if (options.logResults) {
          ApprovalLogger.success(
            'Test passed: [${namer.approvedFileName}] matches [${namer.receivedFileName}]',
          );
        }
      }
    } catch (e, st) {
      if (options.logErrors) {
        ApprovalLogger.exception(e, stackTrace: st);
      }
      rethrow;
    } finally {
      if (options.deleteReceivedFile) {
        if (options.filesPath != null) {
          ApprovalUtils.deleteFile(Namer(options.filesPath!).received);
        } else {
          ApprovalUtils.deleteFile(
            Namer(ApprovalUtils.filePath.split('.').first).received,
          );
        }
      }
    }
  }

  /// Verifies all combinations of inputs for a provided function.
  static void verifyAll<T>(
    List<T> inputs, {
    required String Function(T item) processor,
    Options options = const Options(),
  }) {
    try {
      // Process the combination to get the response
      final response = inputs.map((e) => processor(e));

      final responseString = response.join('\n');

      // Verify the processed response
      verify(responseString, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // Method to encode object to JSON and then verify it
  static void verifyAsJson(
    dynamic encodable, {
    Options options = const Options(),
  }) {
    try {
      // Encode the object into JSON format
      final jsonContent = ApprovalConverter.encodeReflectively(
        encodable,
        includeClassName: true,
      );
      final prettyJson = ApprovalConverter.convert(jsonContent);

      // Call the verify method on encoded JSON content
      verify(prettyJson, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // Method to convert a sequence of objects to string format and then verify it
  static void verifySequence(
    List<dynamic> sequence, {
    Options options = const Options(),
  }) {
    try {
      // Convert the sequence of objects into a multiline string
      final content = sequence.map((e) => e.toString()).join('\n');

      // Call the verify method on this content
      verify(content, options: options);
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
      verify(resultString, options: options);
    } catch (_) {
      rethrow;
    }
  }

  // ================== Combinations ==================

  /// Verifies all combinations of inputs for a provided function.
  static void verifyAllCombinations<T>(
    List<List<T>> inputs, {
    required String Function(Iterable<List<T>> combination) processor,
    Options options = const Options(),
  }) {
    // Generate all combinations of inputs
    final combinations = ApprovalUtils.cartesianProduct(inputs);

    // Iterate over each combination, apply the processor function, and verify the result

    try {
      // Process the combination to get the response
      final response = processor(combinations);

      // Verify the processed response
      verify(response, options: options);
    } catch (_) {
      rethrow;
    }
  }
}
