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
  static String encodeReflectively(Object? object,
      {bool includeClassName = false}) {
    if (object == null) return 'null';
    if (object is num || object is bool) return object.toString();
    if (object is String) return jsonEncode(object);
    if (object is List) return '[${object.map(encodeReflectively).join(', ')}]';
    if (object is Map) {
      return '{${object.entries.map((e) => '"${e.key}": ${encodeReflectively(e.value)}').join(', ')}}';
    }

    final jsonMap = _convertObjectToMap(object);
    if (jsonMap == null) {
      throw UnsupportedError(
          'Cannot serialize object of type ${object.runtimeType}');
    }

    final jsonBody = jsonMap.entries
        .map((e) => '"${e.key}": ${encodeReflectively(e.value)}')
        .join(', ');
    return includeClassName
        ? '{"${_formatClassName(object.runtimeType)}": {$jsonBody}}'
        : '{$jsonBody}';
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

  /// Formats the class name by making its first letter lowercase.
  static String _formatClassName(Type type) {
    final className = type.toString();
    return '${className[0].toLowerCase()}${className.substring(1)}';
  }
}
