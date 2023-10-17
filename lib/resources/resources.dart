import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppResources {
  // Colors
  static const colorBackground = Color(0xFF53C4B8);
  static const colorBackgroundDark = Color(0xFF24ACAC);

  // Padding
  static const paddingPage = EdgeInsets.all(20);
  static const paddingPageHorizontal = EdgeInsets.symmetric(horizontal: 20);
  static const paddingPageVertical = EdgeInsets.symmetric(vertical: 20);
  static const paddingContent = EdgeInsets.all(10);

  // Spacer
  static const spacerTiny = SizedBox(width: 5, height: 5);
  static const spacerSmall = SizedBox(width: 10, height: 10);
  static const spacerMedium = SizedBox(width: 15, height: 15);
  static const spacerLarge = SizedBox(width: 20, height: 20);
  static const spacerExtraLarge = SizedBox(width: 30, height: 30);
  static const spacerHuge = SizedBox(width: 45, height: 45);

  // Border Radius
  static const borderRadiusTiny = BorderRadius.all(Radius.circular(5));
  static const borderRadiusSmall = BorderRadius.all(Radius.circular(10));
  static const borderRadiusMedium = BorderRadius.all(Radius.circular(15));
  static const borderRadiusMax = BorderRadius.all(Radius.circular(500));

  // Duration
  static const durationAnimationMedium = Duration(milliseconds: 250);
  static const durationAnimationShort = Duration(milliseconds: 100);

  // Input formatter
  static maxLengthInputFormatter([int? maxLength = 50]) => LengthLimitingTextInputFormatter(maxLength);   // Must be a new instance for each page
  static get onlyLettersInputFormatter => FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')); // Must be a new instance for each page

  // Validator
  static String? validatorNotEmpty(String? value) => value?.isNotEmpty != true ? textFormMandatory : null;
  static String? validatorMinLength(String? value, int min) => (value == null || value.length < min) ? textFormMandatory : null;

  // String
  static const textFormMandatory = 'Ⓧ Obligatoire';
  static const textFormIncorrect = 'Ⓧ Format incorrect';
}

extension ExtendedDateTime on DateTime {
  static final _formatterDate = DateFormat('d MMMM');

  String toDateString() => _formatterDate.format(this);
}
