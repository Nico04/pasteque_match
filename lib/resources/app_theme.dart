import 'package:flutter/material.dart';

import 'resources.dart';

/// Build App Theme.
///
/// It's NOT a simple variable to allow hot reload to work properly.
/// Should not affect performance much.
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppResources.colorBackground),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: AppResources.borderRadiusSmall,
      ),
      isDense: true,    // Allow icons to be correctly sized
      contentPadding: EdgeInsets.all(15),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: 20,
      ),
    ),
  );
}
