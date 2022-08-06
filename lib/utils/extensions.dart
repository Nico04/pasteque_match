import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

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
