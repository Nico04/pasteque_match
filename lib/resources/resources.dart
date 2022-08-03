import 'package:flutter/material.dart';

class AppResources {
  // Padding
  static const paddingPage = EdgeInsets.all(20);
  static const paddingContent = EdgeInsets.all(10);

  // Spacer
  static const spacerTiny = SizedBox(width: 5, height: 5);
  static const spacerSmall = SizedBox(width: 10, height: 10);
  static const spacerMedium = SizedBox(width: 15, height: 15);
  static const spacerLarge = SizedBox(width: 20, height: 20);
  static const spacerExtraLarge = SizedBox(width: 30, height: 30);
  static const spacerHuge = SizedBox(width: 45, height: 45);

  // Duration
  static const durationAnimationMedium = Duration(milliseconds: 250);
  static const durationAnimationShort = Duration(milliseconds: 100);

  // Validator
  static String? validatorNotEmpty(String? value) => value?.isNotEmpty != true ? textFormMandatory : null;

  // String
  static const textFormMandatory = 'Obligatoire';
}
