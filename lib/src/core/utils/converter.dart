part of '../../../approval_tests.dart';

class ApprovalConverter {
  const ApprovalConverter._();
  static String convert(String jsonString) {
    // Decode the JSON string to a dynamic object
    final decodedJson = jsonDecode(jsonString);
    // Use JsonEncoder with custom indentation
    const encoder = JsonEncoder.withIndent('  ');
    // Convert the dynamic object back to a string with indentation
    return encoder.convert(decodedJson);
  }

  /// `encodeReflectively` is a method that encodes an object to JSON format using reflection.
  static String encodeReflectively(
    Object? object, {
    bool includeClassName = false,
  }) {
    if (object == null) {
      return 'null';
    }

    if (object is List) {
      // Handle lists of objects by iterating through them
      return '[${object.map((item) => encodeReflectively(item)).join(', ')}]';
    }

    if (object is Map) {
      // Handle maps directly
      return '{${object.entries.map((e) => '"${e.key}": ${encodeReflectively(e.value)}').join(', ')}}';
    }

    // Reflect the object
    final InstanceMirror mirror = reflect(object);
    final ClassMirror classMirror = mirror.type;

    if (object is String) {
      // JSON encode strings with proper escaping
      return '"${object.replaceAll('"', '\\"')}"';
    } else if (object is num || object is bool) {
      // Numbers and booleans can be added directly
      return object.toString();
    }

    // Handling custom objects
    final Map<String, String> jsonMap = {};

    // Iterate over the instance variables of the class
    for (final value in classMirror.declarations.values) {
      if (value is VariableMirror && !value.isStatic) {
        final String key = MirrorSystem.getName(value.simpleName);
        final reflectee = mirror.getField(value.simpleName).reflectee;
        jsonMap[key] = encodeReflectively(reflectee);
      }
    }

    // Format the map into JSON
    final String jsonBody = jsonMap.entries
        .map((entry) => '"${entry.key}": ${entry.value}')
        .join(', ');

    if (includeClassName) {
      final String className = MirrorSystem.getName(classMirror.simpleName);
      final String capitalizedClassName =
          '${className[0].toLowerCase()}${className.substring(1)}';
      return '{"$capitalizedClassName": {$jsonBody}}';
    }

    return '{$jsonBody}';
  }
}
