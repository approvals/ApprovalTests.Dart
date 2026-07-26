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

/// Contract for reporters that can tell whether they are usable here.
///
/// [Reporter] deliberately stays a single-method interface, so availability
/// lives in this separate capability contract. Composing reporters such as
/// [FirstWorkingReporter] and [MultiReporter] consult it through
/// [ReporterAvailability.of].
///
/// Implementations must answer without side effects and without launching the
/// underlying tool.
abstract interface class ReporterAvailability implements Reporter {
  /// Whether this reporter can run in the current environment.
  ///
  /// `false` means "cannot run here" — a missing diff tool, an unsupported
  /// platform, an executable that is not installed. It never means "ran and
  /// failed"; an execution failure is surfaced by `report` throwing.
  bool get isAvailable;

  /// Whether [reporter] can run in the current environment.
  ///
  /// A reporter that does not implement [ReporterAvailability] is treated as
  /// always available, so existing custom reporters keep working unchanged.
  static bool of(Reporter reporter) =>
      reporter is! ReporterAvailability || reporter.isAvailable;
}
