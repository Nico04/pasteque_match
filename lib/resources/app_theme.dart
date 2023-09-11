import 'package:flutter/material.dart';

import 'resources.dart';

/// Build App Theme.
///
/// It's NOT a simple variable to allow hot reload to work properly.
/// Should not affect performance much.
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0caba0)),
    useMaterial3: true,
    cardTheme: const CardTheme(
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
      contentPadding: const EdgeInsets.all(15),
    ),
  );
}
