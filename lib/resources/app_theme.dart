import 'package:flutter/material.dart';

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
  );
}
