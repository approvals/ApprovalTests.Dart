// ignore_for_file: avoid_relative_lib_imports

import 'package:approval_tests/approval_tests.dart';
import 'package:starter_project/starter_project.dart';
import 'package:test/test.dart';

void main() {
  // Define all test cases
  const allTestCases = [
    [
      "foo",
      "Aged Brie",
      "Backstage passes to a TAFKAL80ETC concert",
      "Sulfuras, Hand of Ragnaros",
    ],
    [-1, 0, 5, 6, 10, 11],
    [-1, 0, 1, 49, 50],
  ];

  group('Approval Tests for Gilded Rose', () {
    test('should verify all combinations of test cases', () {
      // Perform the verification for all combinations
      Approvals.verifyAllCombinations(
        allTestCases,
        options: const Options(
          comparator: IDEComparator(
            ide: ComparatorIDE.visualStudioCode,
          ),
        ),
        processor: processItemCombination,
      );
    });
  });
}

// Function to process each combination and generate output for verification
String processItemCombination(Iterable<List<dynamic>> combinations) {
  final receivedBuffer = StringBuffer();

  for (final combination in combinations) {
    // Extract data from the current combination
    final String itemName = combination[0] as String;
    final int sellIn = combination[1] as int;
    final int quality = combination[2] as int;

    // Create an Item object representing the current combination
    final Item testItem = Item(itemName, sellIn: sellIn, quality: quality);

    // Passing testItem to the application
    final GildedRose app = GildedRose(items: [testItem]);

    // Updating quality of testItem
    app.updateQuality();

    // Adding the updated item to expectedItems
    receivedBuffer.writeln(testItem.toString());
  }

  // Return a string representation of the updated item
  return receivedBuffer.toString();
}
