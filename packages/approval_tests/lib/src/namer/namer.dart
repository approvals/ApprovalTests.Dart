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

/// `Namer` class is used to generate the file names for the approved and received files.
final class Namer implements ApprovalNamer {
  final String? filePath;
  final FileNamerOptions? options;
  final bool addTestName;
  final String? description;

  const Namer({
    this.filePath,
    this.options,
    this.addTestName = true,
    this.description,
  });

  @override
  String get approved {
    if (options != null) {
      return options!.approved;
    }

    if (description != null) {
      return addTestName
          ? '$filePath.$currentTestName.$_updatedDescription.$approvedExtension'
          : '$filePath.$_updatedDescription.$approvedExtension';
    }
    return addTestName ? '$filePath.$currentTestName.$approvedExtension' : '$filePath.$approvedExtension';
  }

  @override
  String get approvedFileName {
    if (options != null) {
      return options!.approvedFileName;
    }
    if (description != null) {
      return addTestName
          ? '$_fileName.$currentTestName.$_updatedDescription.$approvedExtension'
          : '$_fileName.$_updatedDescription.$approvedExtension';
    }
    return addTestName ? '$_fileName.$currentTestName.$approvedExtension' : '$_fileName.$approvedExtension';
  }

  @override
  String get received {
    if (options != null) {
      return options!.received;
    }

    if (description != null) {
      return addTestName
          ? '$filePath.$currentTestName.$_updatedDescription.$receivedExtension'
          : '$filePath.$_updatedDescription.$receivedExtension';
    }
    return addTestName ? '$filePath.$currentTestName.$receivedExtension' : '$filePath.$receivedExtension';
  }

  @override
  String get receivedFileName {
    if (options != null) {
      return options!.receivedFileName;
    }
    if (description != null) {
      return addTestName
          ? '$_fileName.$currentTestName.$_updatedDescription.$receivedExtension'
          : '$_fileName.$_updatedDescription.$receivedExtension';
    }
    return addTestName ? '$_fileName.$currentTestName.$receivedExtension' : '$_fileName.$receivedExtension';
  }

  @override
  String get currentTestName {
    final testName = Invoker.current?.liveTest.individualName;
    return testName == null ? '' : testName.replaceAll(' ', '_').toLowerCase();
  }

  String get _updatedDescription => description == null ? '' : description!.replaceAll(' ', '_').toLowerCase();

  String get _fileName {
    final path = filePath!;
    final separator = Platform.isWindows ? '\\' : '/';
    return path.split(separator).last.split('.dart').first;
  }

  static const String approvedExtension = 'approved.txt';

  static const String receivedExtension = 'received.txt';
}
