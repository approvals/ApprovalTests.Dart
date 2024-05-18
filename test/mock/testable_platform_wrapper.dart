part of '../approval_test.dart';

/// Mock `WindowsPlatformWrapper` is a class for platform detection.
/// It is used to detect if the current platform is `Windows`.
class WindowsPlatformWrapper implements PlatformWrapper {
  const WindowsPlatformWrapper();

  @override
  bool get isWindows => true;

  @override
  bool get isMacOS => false;

  @override
  bool get isLinux => false;
}

/// Mock `LinuxPlatformWrapper` is a class for platform detection.
/// It is used to detect if the current platform is `Linux`.
class LinuxPlatformWrapper implements PlatformWrapper {
  const LinuxPlatformWrapper();

  @override
  bool get isWindows => false;

  @override
  bool get isMacOS => false;

  @override
  bool get isLinux => true;
}

/// Mock `MacOSPlatformWrapper` is a class for platform detection.
/// It is used to detect if the current platform is `MacOS`.
class MacOSPlatformWrapper implements PlatformWrapper {
  const MacOSPlatformWrapper();

  @override
  bool get isWindows => false;

  @override
  bool get isMacOS => true;

  @override
  bool get isLinux => false;
}
