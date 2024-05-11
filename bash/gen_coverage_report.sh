#!/bin/bash -e
# chmod +x bash/gen_coverage_report.sh
# ./bash/gen_coverage_report.sh

# Test
dart pub global activate coverage
dart run test --coverage=./coverage && dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage

# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

dart pub global deactivate coverage

# Open Coverage Report
open coverage/index.html