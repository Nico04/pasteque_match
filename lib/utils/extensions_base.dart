import 'package:diacritic/diacritic.dart';

/// Separated from [extensions.dart] to allow import from Dart Command program [utils/lib/main.dart]

extension ExtendedString on String {
  /// Normalize a string by removing diacritics and transform to lower case
  String get normalized => removeDiacritics(toLowerCase());

  /// Returns the substring of this string that extends from [startIndex], inclusive, with a length of [length].
  /// If [length] if negative, length will be relative to the total length
  String substringSafe({int? startIndex, int? length}) {
    if (startIndex == null && length == null) return '';

    startIndex ??= 0;

    if (length == null) {
      length = this.length;
    } else {
      length = length.clamp(0, this.length);
    }

    if (startIndex < 0) startIndex = 0;
    if (length < 0) length = this.length + length;

    if (startIndex >= length) return '';

    return substring(startIndex, length);
  }
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
