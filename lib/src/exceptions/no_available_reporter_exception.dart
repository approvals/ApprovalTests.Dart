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

/// Thrown when [FirstWorkingReporter] finds no usable reporter.
final class NoAvailableReporterException implements Exception {
  /// Reporters that were checked, in selection order.
  final List<Reporter> reporters;

  const NoAvailableReporterException({required this.reporters});

  @override
  String toString() {
    final checked = reporters.isEmpty
        ? 'none were configured'
        : reporters.map((r) => r.runtimeType).join(', ');
    return 'No available reporter: $checked.\n'
        'Add an always-available reporter such as CommandLineReporter as the '
        'last entry so mismatches are still reported on headless CI.';
  }
}
