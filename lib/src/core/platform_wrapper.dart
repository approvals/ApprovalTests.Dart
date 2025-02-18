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
