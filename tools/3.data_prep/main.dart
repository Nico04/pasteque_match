// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Pastèque-Match data preparation script
/// A Dart script that takes a ODS file as input, and make some calculation to prepare data.
///
/// Performance note: using ODS file is very slow and may lead to heap overflow. It's way quicker & stabler (no memory leak) using XLSX files.
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Data Preparator ############');

  // Check args
  if (rawArgs.length != 1) {
    print('Arguments must be "[ODS file path]"');
    exit(0);
  }

  // Read names file
  final inputFilePath = rawArgs[0];

  // Load file
  print('Load file');
  final file = File(inputFilePath);
  final bytes = await file.readAsBytes();
  final spreadsheet = SpreadsheetDecoder.decodeBytes(bytes, update: true);
  final tables = spreadsheet.tables;

  // Open BDD table
  const sheetName = 'BDD';

  // Compute total count
  //_computeTotalCount(spreadsheet);

  // Compute hyphenation
  //_computeHyphenation(spreadsheet);

  // Sort names in each group by total count + rename group to highest count
  //sortAndRenameGroups(spreadsheet);

  // Compute whether groups are epicene
  //computeEpiceneGroups(spreadsheet);

  // Compute database stats
  //computeDatabaseStats(spreadsheet);

  // Compute relative total
  computeRelativeTotal(spreadsheet);

  // Save file
  print('Save file');
  if (_askConfirmation('Do you want to save the file ?')) {
    await file.writeAsBytes(spreadsheet.encode());
    print('File saved');
  }

  // Exit program
  print('All done !');
  exit(0);
}

const databaseSheetName = 'BDD';
const groupIdColumnIndex = 0;
const nameColumnIndex = 1;
const genderColumnIndex = 2;
const countColumnIndex = 3;
const totalCountColumnIndex = 4;
const relativeTotalColumnIndex = 5;
const hyphenationColumnIndex = 6;
const epiceneColumnIndex = 7;

const databaseStatsSheetName = 'Stats';
const yearColumnIndex = 0;
const totalColumnIndex = 1;
const statsTotalRowName = 'Total';

bool _askConfirmation(String prompt) {
  print(prompt);
  final response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') return false;
  return true;
}

void computeTotalCount(SpreadsheetDecoder spreadsheet) {
  print('Compute total count');
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Deserialize
      final data = _deserializeData(row[countColumnIndex]);

      // Compute total count
      final totalCount = data.values.reduce((value, element) => value + element);

      // Update sheet
      spreadsheet.updateCell(databaseSheetName, totalCountColumnIndex, rowIndex, totalCount);
    },
  );
}

void computeHyphenation(SpreadsheetDecoder spreadsheet) {
  print('Compute hyphenation');
  const hyphenationChars = ['-', "'"];
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];
      final name = row[nameColumnIndex] as String?;
      if (name == null || name.isEmpty) return;

      // Compute
      final bool hyphenated = hyphenationChars.any(name.contains);

      // Update sheet
      spreadsheet.updateCell(databaseSheetName, hyphenationColumnIndex, rowIndex, hyphenated ? true : false);
    },
  );
}

void sortAndRenameGroups(SpreadsheetDecoder spreadsheet) {
  print('Sort and rename groups');
  _computeEachGroup(
    spreadsheet,
    (groupHeaderRowIndex, namesRows) {
      // Skip groups with only one name
      if (namesRows.length <= 1) return;

      // Sort names by total count
      namesRows.sort((a, b) => (b[totalCountColumnIndex] as num).compareTo(a[totalCountColumnIndex] as num));
      //print('Group ${namesRows.first[nameColumnIndex]}');

      // Rename group to highest count
      spreadsheet.updateCell(databaseSheetName, groupIdColumnIndex, groupHeaderRowIndex, namesRows.first[nameColumnIndex]);

      // Save new row order
      for (int r = 0; r < namesRows.length; r++) {
        final row = namesRows[r];
        for (int c = 0; c < row.length; c++) {
          final value = row[c];
          spreadsheet.updateCell(databaseSheetName, c, groupHeaderRowIndex + 1 + r, value ?? '');
        }
      }
    },
  );
}

void computeEpiceneGroups(SpreadsheetDecoder spreadsheet) {
  print('Compute epicene groups');
  _computeEachGroup(
    spreadsheet,
    (groupHeaderRowIndex, namesRows) {
      // Skip groups with only one name
      if (namesRows.length <= 1) return;

      // Sort names by total count
      namesRows.sort((a, b) => (b[totalCountColumnIndex] as num).compareTo(a[totalCountColumnIndex] as num));

      // Compute epicene
      for (int r1 = 0; r1 < namesRows.length; r1++) {
        final row1 = namesRows[r1];
        final name1 = row1[nameColumnIndex] as String;
        final gender1 = row1[genderColumnIndex] as String;
        for (int r2 = r1 + 1; r2 < namesRows.length; r2++) {
          final row2 = namesRows[r2];
          final name2 = row2[nameColumnIndex] as String;
          final gender2 = row2[genderColumnIndex] as String;
          final epicene = name1 == name2;
          if (epicene && gender1 == gender2) print('/!\\ Warning /!\\ Same name & same gender for: $name1');
          spreadsheet.updateCell(databaseSheetName, epiceneColumnIndex, groupHeaderRowIndex, epicene);
          if (epicene) return;
        }
      }
    },
  );
}

void computeDatabaseStats(SpreadsheetDecoder spreadsheet) {
  print('Compute database stats');
  final stats = <String, int>{};
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Deserialize
      final data = _deserializeData(row[countColumnIndex]);

      // Add to stats
      data.forEach((year, count) {
        stats[year] = (stats[year] ?? 0) + count;
      });
    },
  );

  // Save stats
  final entries = stats.entries.toList(growable: false);
  for (int i = 0; i < entries.length; i++) {
    final entry = entries[i];
    spreadsheet.updateCell(databaseStatsSheetName, yearColumnIndex, i + 1, entry.key);
    spreadsheet.updateCell(databaseStatsSheetName, totalColumnIndex, i + 1, entry.value);
  }
}

void computeRelativeTotal(SpreadsheetDecoder spreadsheet) {
  print('Compute relative total');
  // Read stats
  final stats = _getStats(spreadsheet);
  final totalCount = stats[statsTotalRowName]!;

  // Compute
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Get total
      final total = row[totalCountColumnIndex] as int;

      // Compute relative total
      final relativeTotal = total / totalCount;

      // Update sheet
      spreadsheet.updateCell(databaseSheetName, relativeTotalColumnIndex, rowIndex, relativeTotal);
    },
  );
}

void _computeEachName(SpreadsheetDecoder spreadsheet, void Function(SpreadsheetTable sheet, int rowIndex) task) {
  // Get sheet
  final sheet = spreadsheet.tables[databaseSheetName]!;

  // Compute total count for each name
  int lastPrintedProgress = 0;
  for (int r = 1; r < sheet.rows.length; r++) {   // Ignore header
    // Ignore group headers
    if (_isStringNullOrEmpty(sheet.rows[r][nameColumnIndex])) continue;

    // Compute
    task(sheet, r);

    // Progress
    final progress = (r / sheet.rows.length * 100).toInt();
    if (lastPrintedProgress != progress) print('Progress: ${lastPrintedProgress = progress}%');
  }
}

void _computeEachGroup(SpreadsheetDecoder spreadsheet, void Function(int groupHeaderRowIndex, List<List> namesRows) task) {
  // Get sheet
  final sheet = spreadsheet.tables[databaseSheetName]!;

  // Compute total count for each name
  int lastPrintedProgress = 0;
  int groupHeaderRowIndex = 0;
  final groupRows = <List>[];
  for (int r = 1; r < sheet.rows.length + 1; r++) {   // Ignore header
    // Detect group headers
    final row = sheet.rows.elementAtOrNull(r);
    if (row == null || !_isStringNullOrEmpty(row[0])) {
      // Compute, but ignore empty groups
      if (groupRows.isNotEmpty) {
        task(groupHeaderRowIndex, groupRows);
      }

      // Set new group values
      groupHeaderRowIndex = r;
      groupRows.clear();
    } else {
      // Add name to group
      groupRows.add(List.from(row));    // New list object to allow proper modification
    }

    // Progress
    final progress = (r / sheet.rows.length * 100).toInt();
    if (lastPrintedProgress != progress) print('Progress: ${lastPrintedProgress = progress}%');
  }
}

Map<String, int> _getStats(SpreadsheetDecoder spreadsheet) {
  // Get sheet
  final sheet = spreadsheet.tables[databaseStatsSheetName]!;

  // Build stats
  final stats = <String, int>{};
  for (int r = 1; r < sheet.rows.length; r++) {   // Ignore header
    // Get data
    final row = sheet.rows[r];
    final year = row[yearColumnIndex].toString();
    final total = row[totalColumnIndex] as int;

    // Add to stats
    stats[year] = total;
  }
  return stats;
}

bool _isStringNullOrEmpty(String? s) => s == null || s.isEmpty;

Map<String, int> _deserializeData(String dataRaw) => (jsonDecode(dataRaw) as Map<String, dynamic>).cast<String, int>();
