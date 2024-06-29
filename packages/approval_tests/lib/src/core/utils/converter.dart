part of '../../../approval_tests.dart';

class ApprovalConverter {
  static String convert(String jsonString) {
    final decodedJson = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(decodedJson);
  }

  static String encodeReflectively(
    Object? object, {
    bool includeClassName = false,
  }) {
    if (object == null) {
      return 'null';
    }

    if (object is List) {
      return '[${object.map((item) => encodeReflectively(item)).join(', ')}]';
    }

    if (object is Map) {
      return '{${object.entries.map((e) => '"${e.key}": ${encodeReflectively(e.value)}').join(', ')}}';
    }

    if (object is String) {
      return '"${object.replaceAll('"', '\\"')}"';
    } else if (object is num || object is bool) {
      return object.toString();
    }

    // Attempt to convert custom objects to a map
    final Map<String, dynamic>? jsonMap = _convertObjectToMap(object);

    if (jsonMap == null) {
      throw UnsupportedError(
        'Cannot serialize object of type ${object.runtimeType}',
      );
    }

    final String jsonBody = jsonMap.entries
        .map((entry) => '"${entry.key}": ${encodeReflectively(entry.value)}')
        .join(', ');

    if (includeClassName) {
      final String className = object.runtimeType.toString();
      final String capitalizedClassName =
          '${className[0].toLowerCase()}${className.substring(1)}';
      return '{"$capitalizedClassName": {$jsonBody}}';
    }

    return '{$jsonBody}';
  }

  // Function to dynamically convert an object to a map if it has a toJson method
  static Map<String, dynamic>? _convertObjectToMap(Object object) {
    try {
      // Check if the object has a `toJson` method
      // ignore: avoid_dynamic_calls
      final jsonMap = (object as dynamic).toJson();
      if (jsonMap is Map<String, dynamic>) {
        return jsonMap;
      }
    } catch (e) {
      // If the object doesn't have a `toJson` method, return null
      return null;
    }
    return null;
  }
}
