part of '../../../approval_tests.dart';

/// `MacDiffTools` contains diff tools available on macOS.
final class MacDiffTools {
  static const DiffInfo visualStudioCode = DiffInfo(
    command:
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code',
    arg: '-d',
  );

  static const DiffInfo androidStudio = DiffInfo(
    command: '/Applications/Android Studio.app/Contents/MacOS/studio',
    arg: 'diff',
  );
}

/// `WindowsDiffTools` contains diff tools available on Windows.
final class WindowsDiffTools {
  // TODO: check correct path for Visual Studio Code on Windows
  static const DiffInfo visualStudioCode = DiffInfo(
    command: 'C:\\Program Files\\Microsoft VS Code\\Code.exe',
    arg: '-d',
  );

  // TODO: check correct path for Android Studio on Windows
  static const DiffInfo androidStudio = DiffInfo(
    command: 'C:\\Program Files\\Android\\Android Studio\\bin\\studio64.exe',
    arg: 'diff',
  );
}

/// `LinuxDiffTools` contains diff tools available on Linux.
final class LinuxDiffTools {
  // TODO: check correct path for Visual Studio Code on Linux
  static const DiffInfo visualStudioCode = DiffInfo(
    command: '/usr/bin/code',
    arg: '-d',
  );

  // TODO: check correct path for Android Studio on Linux
  static const DiffInfo androidStudio = DiffInfo(
    command: '/usr/bin/studio',
    arg: 'diff',
  );
}
