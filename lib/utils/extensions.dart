import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/_utils.dart';

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

  /// Clear current context focus.
  /// This is the cleanest, official way.
  void clearFocus() => FocusScope.of(this).unfocus();

  /// Clear current context focus (Second method)
  /// Use this method if [clearFocus] doesn't work.
  void clearFocus2() => FocusScope.of(this).requestFocus(FocusNode());

  /// Validate the enclosing [Form]
  Future<void> validateForm({VoidCallback? onSuccess}) async {
    clearFocus();
    final form = Form.of(this);
    if (form == null) return;

    if (form.validate()) {
      form.save();
      onSuccess?.call();
    }
  }

  void popToRoot() => Navigator.of(this).popUntil((route) => route.isFirst);
}
