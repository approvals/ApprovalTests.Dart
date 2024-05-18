part of '../../approval_tests.dart';

/// `IPlatformWrapper` is an abstract class for platform detection.
abstract interface class IPlatformWrapper {
  bool get isWindows;
  bool get isMacOS;
  bool get isLinux;
}

/// `PlatformWrapper` is a class for platform detection.
class PlatformWrapper implements IPlatformWrapper {
  const PlatformWrapper();

  @override
  bool get isWindows => Platform.isWindows;

  @override
  bool get isMacOS => Platform.isMacOS;

  @override
  bool get isLinux => Platform.isLinux;
}
