#!/bin/bash -e
# chmod +x bash/build_and_test.sh
# ./bash/build_and_test.sh
dart pub get
dart format .
dart fix --apply
dart analyze
dart pub global activate coverage
dart run test --coverage=./coverage && dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage
dart pub global deactivate coverage