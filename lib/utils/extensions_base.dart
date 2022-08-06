import 'package:diacritic/diacritic.dart';

/// Separated from [extensions.dart] to allow import from Dart Command program [utils/lib/main.dart]

extension ExtendedString on String {
  /// Normalize a string by removing diacritics and transform to lower case
  String get normalized => removeDiacritics(toLowerCase());
}

// Cannot import 'package:pasteque_match/utils/extensions.dart', otherwise program throws
extension ExtendedIterable<T> on Iterable<T> {
  /// The first element satisfying test, or null if there are none.
  /// Copied from Flutter.collection package
  /// https://api.flutter.dev/flutter/package-collection_collection/IterableExtension/firstWhereOrNull.html
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
