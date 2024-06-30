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

// Define utility class for approval related operations. It contains methods for converting string cases and retrieving directory or file path.
final class ApprovalUtils {
  static AnsiPen hexToAnsiPen(String hex) {
    final int red = int.parse(hex.substring(0, 2), radix: 16);
    final int green = int.parse(hex.substring(2, 4), radix: 16);
    final int blue = int.parse(hex.substring(4, 6), radix: 16);

    final AnsiPen pen = AnsiPen()..rgb(r: red / 255, g: green / 255, b: blue / 255);
    return pen;
  }

  /// Computes the Cartesian product of a list of lists.
  static Iterable<List<T>> cartesianProduct<T>(List<List<T>> lists) {
    try {
      Iterable<List<T>> result = [[]];
      for (final list in lists) {
        result = result.expand((x) => list.map((y) => [...x, y]));
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static String readFile({
    required String path,
  }) {
    final File file = File(path);
    return file.readAsStringSync().trim();
  }

  static bool isFileExists(String path) {
    final File file = File(path);
    return file.existsSync();
  }

  static String lines(int count) => List.filled(count, '=').join();

  static void deleteFile(String path) {
    try {
      final File file = File(path);
      final bool exists = file.existsSync();
      if (exists) {
        file.deleteSync();
      }
    } catch (_) {
      rethrow;
    }
  }

  static String get commandWhere {
    if (Platform.isWindows) {
      return 'where';
    } else {
      return 'which';
    }
  }
}
