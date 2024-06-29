/// Fizz Buzz kata implementation
List<String> fizzBuzz(int n) {
  final List<String> result = [];

  for (int i = 1; i <= n; i++) {
    // If the current number (`i`) is divisible by both 3 and 5 (or equivalently 15),
    // add the string "FizzBuzz" to the `result` list.
    if (i % 15 == 0) {
      result.add("FizzBuzz");

      // Else, if the current number (`i`) is only divisible by 3,
      // add the string "Fizz" to the `result` list.
    } else if (i % 3 == 0) {
      result.add("Fizz");

      // Else, if the current number (`i`) is only divisible by 5,
      // add the string "Buzz" to the `result` list.
    } else if (i % 5 == 0) {
      result.add("Buzz");

      // If the current number (`i`) is neither divisible by 3 nor 5,
      // add the string representation of that number to the `result` list.
    } else {
      result.add(i.toString());
    }
  }

  return result;
}
