// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

/// Pastèque-Match Data preparator
/// A Dart script that takes raw names from CSV, and export into a new formated CSV
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Data Preparator ############');

  // Check args
  if (rawArgs.length != 3) {
    print('Arguments must be "[raw names with stats file path] [names with phonetics file path] [output file path]"');
    exit(0);
  }

  // Read names file
  final rawNamesCsvRows = await _readCsv(rawArgs[0]);

  // Build list _NameEntry, grouped by name
  print('Build list of name entries');
  final nameEntries = <_NameEntryKey, NameQuantityStatisticsValue>{};
  for (final row in rawNamesCsvRows) {
    final gender = () {
      int genderRaw = row[0];
      if (genderRaw == 1) return NameGender.male;
      if (genderRaw == 2) return NameGender.female;
      throw UnsupportedError('Unsupported case');
    } ();

    String name = row[1];

    final year = () {
      final yearRaw = row[2];
      if (yearRaw == 'XXXX') return 0;
      if (yearRaw is int) return yearRaw;
      throw UnsupportedError('Unsupported case');
    } ();

    int count = row[3];

    final group = nameEntries.putIfAbsent(_NameEntryKey(name, gender), () => {});
    group[year.toString()] = count;
  }

  // Convert to list of Name
  print('Convert to a list of Name');
  final rawNames = <Name>[];
  for (final nameEntry in nameEntries.entries) {
    rawNames.add(Name(
      name: nameEntry.key.name,
      gender: nameEntry.key.gender,
      stats: NameQuantityStatistics(nameEntry.value),
    ));
  }

  // Remove short names
  print('Remove short names');
  rawNames.removeWhere((name) => name.length <= 2);

  // Prepare for grouping
  final rawGroups = SplayTreeMap<String, List<Name>>();

  // Group names that have same name (but different gender indeed)
  print('Group names entries with same name');
  for (final name in rawNames) {
    final list = rawGroups.putIfAbsent(name.name, () => []);
    list.add(name);
  }

  // Read phonetic file
  final phoneticsCsvRows = await _readCsv(rawArgs[1]);

  // Convert to a Map
  final phoneticsMap = <String, (String, String)>{};
  for (final row in phoneticsCsvRows) {
    phoneticsMap[row[0]] = (row[1], row[2]);
  }

  // Merge names with same phonetic
  print('Merge names with same phonetic');
  var lastPrintTime = DateTime.now();

  final namesToCheck = Set.of(rawGroups.keys);
  while (namesToCheck.isNotEmpty) {
    if (DateTime.now().difference(lastPrintTime) > const Duration(seconds: 1)) {
      print('${namesToCheck.length} names left to check');
      lastPrintTime = DateTime.now();
    }

    // Take first element of list
    final name = namesToCheck.first;

    // Remove it from list of names to check
    namesToCheck.remove(name);

    // Search for corresponding phonetic entry
    final phonetics = phoneticsMap[name];

    // Ignore if missing
    if (phonetics == null) {
      print('/!\\ $name is missing from Phonetics');
      continue;
    }

    // Build a list of names with matching phonetics
    final matches = List.of([MapEntry(name, phonetics)]);   // Need list to keep sorted by added order
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];

      // Search for names with matching phonetics
      final newMatches = phoneticsMap.entries.where((e) => e.value.$1 == match.value.$1 || e.value.$2 == match.value.$2);

      // Merge new matches to main list
      for (final newMatch in newMatches) {
        // Add only if not already present
        if (!matches.any((e) => e.key == newMatch.key)) {
          matches.add(newMatch);
        }
      }
    }

    // Convert to a simple set of names
    final matchingNames = matches.map((e) => e.key).toSet();

    // Remove main name
    matchingNames.remove(name);

    // Get group
    final mainGroup = rawGroups[name]!;

    // Move all matching group to main group
    for (final matchingName in matchingNames) {
      // Remove group from main list
      final group = rawGroups.remove(matchingName);

      // Add removed group content to main group list, if exists
      if (group != null) mainGroup.addAll(group);
    }

    // Remove matching names from names to check list
    namesToCheck.removeAll(matchingNames);
  }
  print('${rawGroups.length} groups created');

  // Convert to rows for CSV export
  final rows = <List<String>>[
    // Header
    ['Group ID', 'Prénom', 'Genre', 'Effectif / Quantité'],
  ];
  for (final groupEntry in rawGroups.entries) {
    rows.add([groupEntry.key.normalized]);
    for (final name in groupEntry.value) {
      rows.add(['', name.name.capitalized, name.gender.name, json.encode(name.stats.toJson())]);
    }
  }

  // Save as CSV
  print('Save as CSV');
  final outputFilePath = rawArgs[2];
  await _saveCsv(rows, outputFilePath);

  // Exit program
  exit(0);
}

Future<List<List<dynamic>>> _readCsv(String filePath) async {
  // Read file
  print('[CSV] Load file $filePath}');
  final file = File(filePath);
  if(!await file.exists()) {
    print('[CSV] File does not exists');
    exit(0);
  }
  final csvRaw = await file.readAsString();
  print('[CSV] File loaded');

  // Read CSV
  print('[CSV] Start converting');
  return const CsvToListConverter(fieldDelimiter: ';', ).convert(csvRaw);
}

Future<void> _saveCsv(List<List<dynamic>> rows, String outputFilePath) async {
  // Convert to CSV
  print('[CSV] Convert to CSV');
  final content = const ListToCsvConverter().convert(rows, fieldDelimiter: ';');

  // Save to a file
  final file = File(outputFilePath);
  await file.writeAsString(content);
  print('[CSV] File saved $outputFilePath');
}

class _NameEntryKey {
  const _NameEntryKey(this.name, this.gender);

  final String name;
  final NameGender gender;

  @override
  bool operator ==(Object other) => other is _NameEntryKey && other.name == name && other.gender == gender;

  @override
  int get hashCode => name.hashCode ^ gender.hashCode;
}

class _NameEntryData {
  const _NameEntryData({required this.year, required this.count});

  final int year;
  final int count;
}
