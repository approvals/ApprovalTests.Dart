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

/// A utility class for converting and encoding objects into JSON format.
///
/// The [ApprovalConverter] class provides methods to format JSON strings
/// with indentation and to encode objects reflectively, supporting basic
/// types, lists, maps, and objects with a `toJson` method.
final class ApprovalConverter {
  /// Prevents instantiation of [ApprovalConverter].
  /// This is a utility class and should not be instantiated.
  const ApprovalConverter._();

  /// Converts a raw JSON string into a formatted, indented JSON string.
  ///
  /// - [jsonString]: A valid JSON string.
  ///
  /// Returns:
  /// A properly indented JSON string.
  static String convert(String jsonString) {
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonString));
  }

  /// Recursively encodes an object into a JSON-compatible string.
  ///
  /// Supports basic types, lists, maps, and objects with a `toJson` method.
  /// Optionally includes the class name as a wrapper for custom objects.
  ///
  /// - [object]: The object to be encoded.
  /// - [includeClassName]: If `true`, wraps custom objects with their class name.
  ///
  /// Returns:
  /// A JSON-compatible string representation of the object.
  static String encodeReflectively(
    Object? object, {
    bool includeClassName = false,
  }) {
    final normalized = _normalizeForJson(
      object,
      includeClassName: includeClassName,
      isRoot: true,
    );
    return jsonEncode(normalized);
  }

  /// Converts an object into a map if it has a `toJson` method.
  ///
  /// - [object]: The object to convert.
  ///
  /// Returns:
  /// A `Map<String, dynamic>` if the object has a `toJson` method, otherwise `null`.
  static Map<String, dynamic>? _convertObjectToMap(Object object) {
    try {
      return (object as dynamic).toJson() as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static Object? _normalizeForJson(
    Object? value, {
    bool includeClassName = false,
    bool isRoot = false,
  }) {
    if (value == null || value is num || value is bool) {
      return value;
    }
    if (value is String) {
      return value;
    }
    if (value is List) {
      return value
          .map((item) => _normalizeForJson(item, includeClassName: false))
          .toList();
    }
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(
          key.toString(),
          _normalizeForJson(mapValue, includeClassName: false),
        ),
      );
    }

    final jsonMap = _convertObjectToMap(value);
    if (jsonMap == null) {
      throw UnsupportedError(
        'Cannot serialize object of type ${value.runtimeType}',
      );
    }

    final normalizedMap = jsonMap.map(
      (key, mapValue) => MapEntry(
        key,
        _normalizeForJson(mapValue, includeClassName: false),
      ),
    );

    if (includeClassName && isRoot) {
      return {_formatClassName(value.runtimeType): normalizedMap};
    }

    return normalizedMap;
  }

  /// Formats the class name by making its first letter lowercase.
  static String _formatClassName(Type type) {
    final className = type.toString();
    return '${className[0].toLowerCase()}${className.substring(1)}';
  }
}
