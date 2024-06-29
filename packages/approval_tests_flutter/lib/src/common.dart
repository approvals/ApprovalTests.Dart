import 'dart:io';

const topBar = '▶▶▶▶';
const bottomBar = '◀◀◀◀';

/// [String] extension
extension StringApprovedExtension on String {
  /// git diff complains when file doesn't end in newline. This getter ensures a string does.
  String get endWithNewline => endsWith('\n') ? this : '$this\n';
}

extension DirectoryApprovedExtension on Directory {
  Set<File> filesWithExtension(String extension) {
    final fileSystemEntities = listSync().where((entity) => entity is File && entity.path.endsWith(extension));
    return fileSystemEntities.whereType<File>().toSet();
  }
}
