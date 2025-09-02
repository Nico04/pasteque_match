import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/_utils.dart';

extension ExtendedRandom on Random {
  /// Generates a random integer uniformly distributed in the range from [min], inclusive, to [max], inclusive.
  int nextIntInRange(int min, int max) {
    assert(min <= max);
    return nextInt(max - min + 1) + min;
  }
}

extension ExtendedObjectIterable<T extends Object?> on Iterable<T> {
  /// Converts each element to a String and concatenates the strings, ignoring null and empty values.
  String joinNotEmpty(String separator) => map((e) => e?.toString())
      .where((string) => !isStringNullOrEmpty(string))
      .join(separator);

  /// Returns a string separated by a newline character for each non-null element
  String toLines() => joinNotEmpty('\n');

  /// Return true if there is strictly one non-null element
  bool singleNotNull() => where((e) => e != null).length == 1;
}

extension ExtendedBuildContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get canPop => ModalRoute.of(this)?.canPop == true;

  void popToRoot() => Navigator.of(this).popUntil((route) => route.isFirst);
}

extension ExtendedColor on Color {
  Color get foregroundTextColor => computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
