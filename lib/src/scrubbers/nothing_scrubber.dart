/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

part of '../../approval_tests.dart';

/// A class named `ScrubNothing` that implements the `Scrubber` interface.
/// `ScrubNothing` is default scrubber that does nothing.
class ScrubNothing implements ApprovalScrubber {
  const ScrubNothing();

  @override
  String scrub(String input) => input;
}
