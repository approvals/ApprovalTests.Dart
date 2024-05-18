part of '../../../../approval_tests.dart';

/// `MacDiffTools` contains diff tools available on macOS.
final class MacDiffTools {
  static const DiffInfo visualStudioCode = DiffInfo(
    command:
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code',
    arg: '-d',
    name: 'code',
  );

  static const DiffInfo androidStudio = DiffInfo(
    command: '/Applications/Android Studio.app/Contents/MacOS/studio',
    arg: 'diff',
    name: 'studio',
  );
}

/// `WindowsDiffTools` contains diff tools available on Windows.
final class WindowsDiffTools {
  static const DiffInfo visualStudioCode = DiffInfo(
    command: 'C:\\Program Files\\Microsoft VS Code\\bin\\code',
    arg: '-d',
    name: 'code',
  );

  // TODO: check correct path for Android Studio on Windows
  static const DiffInfo androidStudio = DiffInfo(
    command: 'C:\\Program Files\\Android\\Android Studio\\bin\\studio64.exe',
    arg: 'diff',
    name: 'studio',
  );
}

/// `LinuxDiffTools` contains diff tools available on Linux.
final class LinuxDiffTools {
  // TODO: check correct path for Visual Studio Code on Linux
  static const DiffInfo visualStudioCode = DiffInfo(
    command: '/snap/bin/code',
    arg: '-d',
    name: 'code',
  );

  // TODO: check correct path for Android Studio on Linux
  static const DiffInfo androidStudio = DiffInfo(
    command: '/snap/bin/studio',
    arg: 'diff',
    name: 'studio',
  );
}
