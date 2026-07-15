import 'dart:io';

/// Replaces an approval artifact, tolerating transient Windows file locks.
final class ApprovalFileReplacer {
  static const maxWindowsAttempts = 100;
  static const windowsRetryDelay = Duration(milliseconds: 1);

  final bool _isWindows;
  final void Function(Duration) _wait;

  ApprovalFileReplacer({
    bool? isWindows,
    void Function(Duration) wait = sleep,
  })  : _isWindows = isWindows ?? Platform.isWindows,
        _wait = wait;

  void replace({required File replacement, required File replaced}) {
    for (var attempt = 1; attempt <= maxWindowsAttempts; attempt++) {
      try {
        replacement.renameSync(replaced.path);
        return;
      } on PathAccessException catch (error) {
        if (!_shouldRetry(error, replaced, attempt)) {
          rethrow;
        }
        _wait(windowsRetryDelay);
      }
    }
  }

  bool _shouldRetry(
    PathAccessException error,
    File replaced,
    int attempt,
  ) {
    if (!_isWindows ||
        attempt >= maxWindowsAttempts ||
        !replaced.existsSync()) {
      return false;
    }

    return switch (error.osError?.errorCode) {
      5 || 32 || 33 => true,
      _ => false,
    };
  }
}
