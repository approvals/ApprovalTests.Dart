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

/// `ApprovalNamer` is an abstract class that provides methods to generate the file names for the approved and received files.
abstract interface class ApprovalNamer {
  /// A getter named `approved` that returns the string `'file_name.test_name.approved.txt'`.
  String get approved;

  /// A getter named `received` that returns the string `'file_name.test_name.received.txt'`.
  String get received;

  /// A getter named `approvedFileName` that returns the string `'file_name.approved.txt'`.
  String get approvedFileName;

  /// A getter named `receivedFileName` that returns the string `'file_name.received.txt'`.
  String get receivedFileName;

  /// A getter named `currentTestName` that returns the current test name.
  String get currentTestName;
}
