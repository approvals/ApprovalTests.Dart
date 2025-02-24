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

/// A utility class for approval-related operations.
///
/// Provides methods for converting hex colors to ANSI pen colors, computing
/// Cartesian products, reading and managing files, and retrieving system commands.
final class ApprovalUtils {
  /// Converts a hex color code to an [AnsiPen] for terminal styling.
  ///
  /// - [hex]: A 6-character hex string representing an RGB color.
  ///
  /// Returns:
  /// An [AnsiPen] configured with the specified color.
  static AnsiPen hexToAnsiPen(String hex) {
    final int red = int.parse(hex.substring(0, 2), radix: 16);
    final int green = int.parse(hex.substring(2, 4), radix: 16);
    final int blue = int.parse(hex.substring(4, 6), radix: 16);
    return AnsiPen()..rgb(r: red / 255, g: green / 255, b: blue / 255);
  }

  /// Computes the Cartesian product of a list of lists.
  ///
  /// - [lists]: A list of lists containing elements of type `T`.
  ///
  /// Returns:
  /// An iterable containing lists representing the Cartesian product.
  static Iterable<List<T>> cartesianProduct<T>(List<List<T>> lists) {
    return lists.fold(<List<T>>[[]],
        (result, list) => result.expand((x) => list.map((y) => [...x, y])));
  }

  /// Reads the contents of a file and trims any extra whitespace.
  ///
  /// - [path]: The file path to read from.
  ///
  /// Returns:
  /// A string containing the file's contents.
  static String readFile(String path) => File(path).readAsStringSync().trim();

  /// Checks if a file exists at the specified path.
  ///
  /// - [path]: The file path to check.
  ///
  /// Returns:
  /// `true` if the file exists, otherwise `false`.
  static bool isFileExists(String path) => File(path).existsSync();

  /// Generates a separator line of the specified length.
  ///
  /// - [count]: The number of '=' characters in the line.
  ///
  /// Returns:
  /// A string containing the separator line.
  static String lines(int count) => '=' * count;

  /// Deletes a file if it exists.
  ///
  /// - [path]: The file path to delete.
  ///
  /// Throws:
  /// Any exception encountered during deletion.
  static void deleteFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  /// Retrieves the system command for finding executables.
  ///
  /// Returns:
  /// `'where'` on Windows, `'which'` on other platforms.
  static String get commandWhere => Platform.isWindows ? 'where' : 'which';
}
