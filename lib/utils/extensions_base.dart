import 'dart:math';
import 'package:diacritic/diacritic.dart';

/// Separated from [extensions.dart] to allow import from Dart Command program [utils/lib/main.dart]

extension ExtendedDouble on double {
  double roundToDecimals(int decimals){
    final mod = pow(10.0, decimals);
    return ((this * mod).round().toDouble() / mod);
  }
}

extension ExtendedString on String {
  /// Returns the plural of this string if [count] is greater than 1.
  String plural(num count) => this + (count >= 2 ? 's' : '');

  /// Normalize string by removing diacritics and transform to lower case
  String get normalized => removeDiacritics(toLowerCase());

  /// Capitalize string
  /// First letter to upper case, all others to lower
  String get capitalized => this[0].toUpperCase() + substring(1).toLowerCase();

  /// Capitalize string - Full version
  /// First letter of string, AND all first letters after a space or a '-' to upper case, all others to lower
  String get capitalizedFull {
    // Separators
    const separators = [' ', '-'];

    // For each separator
    var s = this;
    for (final separator in separators) {
      // Split string
      final parts = s.split(separator);

      // Capitalize each part
      for (int i = 0; i < parts.length; i++) {
        parts[i] = parts[i].capitalized;
      }

      // Re-join
      s = parts.join(separator);
    }

    // Return value
    return s;
  }

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

  /// Constructs a new [DateTime] instance based on this String.
  /// Expected format is 'dd-MM'.
  DateTime? tryParseDate() {
    // Check format
    final regExp = RegExp(r'(\d{1,2})-(\d{1,2})');
    final match = regExp.firstMatch(this);
    if (match == null) return null;

    // Parse
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    if (day == null || month == null) return null;

    // Return value
    return DateTime(2020, month, day);    // 2020 is a leap year (so it works for 29/02)
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

  /// Returns the first element, or null if empty.
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }

  /// Get element at [index], and return null if not in range.
  T? elementAtOrNull(int? index) {
    if (index == null || index < 0 || index >= length) return null;
    return elementAt(index);
  }

  /// Sum each element of the iterable.
  /// Use [toNum] to convert element to a numeric value.
  /// From https://github.com/mythz/dart-linq-examples
  int sum([int Function(T)? toNum]) {
    assert(toNum != null || T == int);
    return fold<int>(0, (value, element) => value + (toNum?.call(element) ?? element as int));
  }

  /// The current elements of this iterable modified by [toElement].
  /// Like [map] but pass the current index in [toElement].
  Iterable<E> mapIndexed<E>(E Function(int index, T item) toElement) sync* {
    var index = 0;
    for (final item in this) {
      yield toElement(index, item);
      index++;
    }
  }
}

extension ExtendedNullableIterable<T> on Iterable<T?> {
  /// Returns a new lazy [Iterable] with all elements that are NOT null
  Iterable<T> whereNotNull() => where((element) => element != null).cast();
}

extension ExtendedList<T> on List<T> {
  /// Insert [widget] between each member of this list
  void insertBetween(T item, {bool includeEnds = false}) {
    if (includeEnds) {
      if (isNotEmpty) {
        for (var i = length; i >= 0; i--) insert(i, item);
      }
    } else {
      if (length > 1) {
        for (var i = length - 1; i > 0; i--) insert(i, item);
      }
    }
  }

  /// Removes the first occurrence of each element in [elements] from this list, if present.
  void removeAll(Iterable<T> elements) {
    for (var element in elements) {
      remove(element);
    }
  }
}

extension ExtendedMap<K, V> on Map<K, V> {
  /// Removes all [keys] and its associated values, if present, from the map.
  void removeAll(Iterable<K> keys) {
    for (var key in keys) {
      remove(key);
    }
  }
}
