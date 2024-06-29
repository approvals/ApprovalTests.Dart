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
    command: 'C:\\Program Files\\Microsoft VS Code\\bin\\code.cmd',
    arg: '-d',
    name: 'code',
  );

  static const DiffInfo androidStudio = DiffInfo(
    command: 'C:\\Program Files\\Android\\Android Studio\\bin\\studio64.exe',
    arg: 'diff',
    name: 'studio64',
  );
}

/// `LinuxDiffTools` contains diff tools available on Linux.
final class LinuxDiffTools {
  static const DiffInfo visualStudioCode = DiffInfo(
    command: '/snap/bin/code',
    arg: '-d',
    name: 'code',
  );

  static const DiffInfo androidStudio = DiffInfo(
    command: '/snap/bin/android-studio',
    arg: 'diff',
    name: 'android-studio',
  );
}
