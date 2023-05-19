// ignore_for_file: avoid_print

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:pasteque_match/models/name.dart';

/// Pastèque-Match Data preparator
/// A Dart script that takes raw names from CSV, and export into a new formated CSV
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Data Preparator ############');

  // Check args
  if (rawArgs.length != 2) {
    print('Arguments must be "[raw names with stats file path] [names with phonetics file path]"');
    exit(0);
  }

  // Read names file
  final rawNamesCsvRows = await _readCsv(rawArgs[0]);

  // Build list _NameEntry, grouped by name
  final groupedNameEntries = <String, List<_NameEntry>>{};
  for (final row in rawNamesCsvRows) {
    final gender = () {
      int genderRaw = row[0];
      if (genderRaw == 1) return NameGender.male;
      if (genderRaw == 2) return NameGender.female;
      throw UnimplementedError('Unhandled case');
    } ();

    String name = row[1];

    final year = () {
      final yearRaw = row[2];
      if (yearRaw == 'XXXX') return 0;
      if (yearRaw is int) return yearRaw;
      throw UnimplementedError('Unhandled case');
    } ();

    int count = row[3];

    final group = groupedNameEntries.putIfAbsent(name, () => []);
    group.add(_NameEntry(
      name: name,
      gender: gender,
      year: year,
      count: count,
    ));
  }

  // Merge entries to build a list of Name
  final rawNames = <Name>[];
  for (final nameEntries in groupedNameEntries.values) {
    final values = {
      NameGender.male: <int, int>{},
      NameGender.female: <int, int>{},
    };

    for (final nameEntry in nameEntries) {
      values[nameEntry.gender]![nameEntry.year] = nameEntry.count;
    }

    final gender = () {
      final hasMale = values[NameGender.male]!.isNotEmpty;
      final hasFemale = values[NameGender.female]!.isNotEmpty;
      if (hasMale && hasFemale) return NameGender.unisex;
      if (hasMale) return NameGender.male;
      if (hasFemale) return NameGender.female;
      throw UnimplementedError('Unhandled case');
    } ();

    rawNames.add(Name(
      name: nameEntries.first.name,
      gender: gender,
      stats: NameQuantityStatistics(
        male: NameGenderQuantityStatistics(values[NameGender.male]!),
        female: NameGenderQuantityStatistics(values[NameGender.female]!),
      ),
    ));
  }

  // Remove short names
  rawNames.removeWhere((name) => name.length <= 2);


  // Read phonetic file
  final phoneticsCsvRows = await _readCsv(rawArgs[1]);

  // Merge names with same phonetic
  final names = <Name>[];
  for (final name in rawNames) {

  }

  // Save as CSV
  // TODO

  // Exit program
  exit(0);
}

Future<List<List<dynamic>>> _readCsv(String filePath) async {
  // Read file
  print('Load file');
  final file = File(filePath);
  if(!await file.exists()) {
  print('File does not exists');
  exit(0);
  }
  final csvRaw = await file.readAsString();
  print('File loaded');

  // Read CSV
  print('Start converting');
  return const CsvToListConverter(fieldDelimiter: ';', ).convert(csvRaw);
}

class _NameEntry {
  const _NameEntry({required this.name, required this.gender, required this.year, required this.count});

  final String name;
  final NameGender gender;
  final int year;
  final int count;
}