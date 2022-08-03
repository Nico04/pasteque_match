// ignore_for_file: avoid_print

//import 'dart:io';

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:pasteque_match/models/name.dart';

/// Pastèque-Match Database Builder
/// Utility program to import a CSV file to the Firestore database
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Database Builder ############');

  // Ask user to check database status
  print('Have you first completely deleted the "names" collection in the database ? ');
  var response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') {
    print('Go to Firestore console and delete the "names" collection first');
    exit(0);
  }

  // Check args
  if (rawArgs.length != 1) {
    print('Input file argument missing');
    exit(0);
  }

  // Read file
  print('Load file');
  final filePath = rawArgs.first;
  final file = File(filePath);
  if(!await file.exists()) {
    print('File does not exists');
    exit(0);
  }
  final csvRaw = await file.readAsString();
  print('File loaded');

  // Read CSV
  print('Start converting');
  final csvRows = const CsvToListConverter(fieldDelimiter: ';').convert(csvRaw);

  // Convert to dart class
  final names = <Name>[];
  for (final row in csvRows) {
    // Name
    final rawNames = (row[0] as String).split('/');
    final name = rawNames.first.trim();
    final otherNames = rawNames.length >= 2 ? rawNames.skip(1).map((name) => name.trim()).toList(growable: false) : const <String>[];

    // Gender
    final gender = NameGender.values.firstWhereOrNull((value) => value.name == row[1]);
    if (name.isEmpty || gender == null) continue;

    // Build object
    names.add(Name(
      name: name,
      gender: gender,
      otherNames: otherNames,
    ));
  }
  print('${names.length} elements converted');

  // Ask confirmation
  print('Are you sure you want to add ${names.length} names to the database ?');
  response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') exit(0);

  // Send data to database
  print('Sending data to database');
  Firestore.initialize('pasteque-match');
  final collectionRef = Firestore.instance.collection("names");
  for (final name in names) {
    await collectionRef.add(name.toJson());
  }
  print('Data sent');
  exit(0);
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
