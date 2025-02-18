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

final class FileNamerOptions {
  final String folderPath;
  final String fileName;
  final String testName;
  final String? description;

  const FileNamerOptions({
    required this.folderPath,
    required this.fileName,
    required this.testName,
    required this.description,
  });

  String get approved => '$folderPath/$approvedFileName';

  String get received => '$folderPath/$receivedFileName';

  String get approvedFileName {
    if (description != null) {
      return '$fileName.$testName.$_updatedDescription.approved.txt';
    }
    return '$fileName.$testName.approved.txt';
  }

  String get receivedFileName {
    if (description != null) {
      return '$fileName.$testName.$_updatedDescription.received.txt';
    }
    return '$fileName.$testName.received.txt';
  }

  String get _updatedDescription =>
      description == null ? '' : description!.replaceAll(' ', '_');
}
