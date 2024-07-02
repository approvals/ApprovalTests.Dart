// ignore_for_file: avoid_print

import 'dart:async';

import 'package:approval_tests/approval_tests.dart';
import 'package:approval_tests_flutter/src/get_widget_names.dart';
import 'package:approval_tests_flutter/src/widget_meta/collect_widgets_meta_data.dart'
    as widgets_meta_data;
import 'package:flutter_test/flutter_test.dart';

Set<String>? _widgetNames;

class ApprovalWidgets {
  static const FilePathExtractor filePathExtractor =
      FilePathExtractor(stackTraceFetcher: StackTraceFetcher());

  /// Initializes the approval test by building a database of project classes.
  ///
  /// Typically called from within flutter_tests function 'setUpAll'
  static Future<Set<String>> setUpAll() async {
    final completer = Completer<Set<String>>();
    await getWidgetNames().then((value) {
      _widgetNames = value;
      completer.complete(value);
    });
    return completer.future;
  }

  static Set<String>? get widgetNames => _widgetNames;
}

/// [_globalApprovalTest] resolves the name conflict with [WidgetTester.approvalTest]
Future<void> Function(String?, String, Options?) _globalApprovalTest =
    (description, value, options) async {
  Approvals.verify(
    value,
    options: options != null
        ? options.copyWith(
            scrubber: options.scrubber,
            approveResult: options.approveResult,
            comparator: options.comparator,
            reporter: options.reporter,
            deleteReceivedFile: options.deleteReceivedFile,
            namer: Namer(
              filePath: options.namer?.filePath,
              options: options.namer?.options,
              addTestName: options.namer?.addTestName ?? true,
              description: description,
            ),
            logErrors: options.logErrors,
            logResults: options.logResults,
            includeClassNameDuringSerialization:
                options.includeClassNameDuringSerialization,
          )
        : Options(
            namer: Namer(
              description: description,
            ),
          ),
  );
};

extension WidgetTesterApprovedExtension on WidgetTester {
  /// Returns the meta data for the widgets for comparison during the approval test
  Future<String> get widgetsString async {
    final completer = Completer<String>();
    assert(_widgetNames != null, '''
    Looks like Approved.initialize() was not called before running an approvalTest. Typically, 
    this issue is solved by calling Approved.initialize() from within setUpAll:
    
        void setUpAll(() async {
          await Approved.initialize();
        });
''');

    await widgets_meta_data
        .collectWidgetsMetaData(
      this,
      outputMeta: true,
      verbose: false,
      widgetNames: ApprovalWidgets.widgetNames,
    )
        .then((stringList) {
      completer.complete(stringList.join('\n'));
    });

    return completer.future;
  }

  /// Performs an approval test.
  ///
  /// [description] is the name of the test. It is appended to the description in [Tester].
  /// [textForReview] is the meta data text used in the approval test.
  Future<void> approvalTest({
    String? description,
    String? textForReview,
    Options? options,
  }) async {
    final resultCompleter = Completer<void>();
    final widgetsMetaCompleter = Completer<String>();

    // If no text passed, then get the widget meta from the widget tree
    if (textForReview == null) {
      await widgetsString.then((value) {
        widgetsMetaCompleter.complete(value);
      });
    } else {
      widgetsMetaCompleter.complete(textForReview);
    }
    await widgetsMetaCompleter.future.then((value) {
      resultCompleter
          .complete(_globalApprovalTest(description, value, options));
    });
    return resultCompleter.future;
  }

  /// Output expect statements to the console.
  Future<void> printExpects() => widgets_meta_data.printExpects(this);
}
