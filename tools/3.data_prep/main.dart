// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:pasteque_match/utils/extensions_base.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Pastèque-Match data preparation script
/// A Dart script that takes a XLSX/ODS file as input, and make some calculation to prepare data.
///
/// Performance note: using ODS file is very slow and may lead to heap overflow. It's way quicker & stabler (no memory leak) using XLSX files.
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Data Preparator ############');

  // Check args
  if (rawArgs.length != 1) {
    print('Arguments must be "[XLSX/ODS file path]"');
    exit(0);
  }

  // Read names file
  final inputFilePath = rawArgs[0];

  // Load file
  print('Load file');
  final (file, spreadsheet) = _readSpreadsheetFile(inputFilePath);

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
  //computeRelativeTotal(spreadsheet);    // TODO remove ?

  // Compute relative count
  //computeRelativeCount(spreadsheet);

  // Build graphs
  //buildGraphs(spreadsheet);

  // Compute popularity
  //computePopularity(spreadsheet);

  // Count names per group
  //countNamesPerGroup(spreadsheet);

  // Compute name length stats
  //computeNameLengthStats(spreadsheet);

  // Add Saints
  addSaints(spreadsheet);

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
const rareNamesFieldName = '_prenoms_rares';
const groupIdColumnIndex = 0;
const nameColumnIndex = 1;
const genderColumnIndex = 2;
const countColumnIndex = 3;
const totalCountColumnIndex = 4;
const relativeCountColumnIndex = 5;
const popularityColumnIndex = 6;
const hyphenationColumnIndex = 7;
const saintsColumnIndex = 8;
const epiceneColumnIndex = 9;

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
      final data = _deserializeData<int>(row[countColumnIndex]);

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
      // Quick handle for groups with only one name
      if (namesRows.length <= 1) {
        spreadsheet.updateCell(databaseSheetName, epiceneColumnIndex, groupHeaderRowIndex, false);
        return;
      }

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
      final data = _deserializeData<int>(row[countColumnIndex]);

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

/* TODO remove ?
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
}*/

void computeRelativeCount(SpreadsheetDecoder spreadsheet) {
  print('Compute relative count');
  // Read stats
  final stats = _getStats(spreadsheet);

  // Compute
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Deserialize
      final data = _deserializeData<int>(row[countColumnIndex]);

      // Compute relative count for each year
      final relativeCounts = <String, double>{};
      data.forEach((year, count) {
        final total = stats[year]!;
        final relativeCount = count / total;
        relativeCounts[year] = relativeCount;
      });

      // Update sheet
      spreadsheet.updateCell(databaseSheetName, relativeCountColumnIndex, rowIndex, jsonEncode(relativeCounts));
    },
  );
}

void buildGraphs(SpreadsheetDecoder spreadsheet) {
  print('Build graphs');
  const names = ['Léon', 'Abdel', 'Josephine', 'Léo', 'Salma', 'Marie', 'Daenerys', 'Gérard', 'Georgette', 'Ethan', 'Nicolas', 'Prisca', 'Louis'];

  // Column header
  const graphSheetName = 'Graphs';
  const firstDataRowIndex = 1;
  const firstYear = 1900;
  const lastYear = 2021;
  final columnHeaderMap = {
    for (var i = 0; i <= (lastYear - firstYear); i++)
      i + firstYear: firstDataRowIndex + i
  };
  columnHeaderMap.forEach((key, value) {
    spreadsheet.updateCell(graphSheetName, 0, value, key);
  });

  final filledNames = <String>{};

  // For each name
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];
      final name = row[nameColumnIndex] as String?;

      // Only compute graphs for specific names
      if (!names.contains(name)) return;

      // Only compute graphs once per name
      if (filledNames.contains(name)) return;

      // Indexes
      final nameIndex = names.indexOf(name!);
      final newNameColumnIndex = 1 + nameIndex;

      // Deserialize
      final data = _deserializeData<int>(row[countColumnIndex]);

      // Add header
      spreadsheet.updateCell(graphSheetName, newNameColumnIndex, 0, name);

      // Add data to graph sheet
      for (final entry in columnHeaderMap.entries) {
        final value = data[entry.key.toString()];
        spreadsheet.updateCell(graphSheetName, newNameColumnIndex, entry.value, value ?? 0);
      }
      filledNames.add(name);
    },
  );
}

void computePopularity(SpreadsheetDecoder spreadsheet) {
  print('Compute popularity');

  // Compute weighted sum
  final weightedSums = <int, double>{};
  (double, String) min = (double.infinity, '-');
  (double, String) max = (double.negativeInfinity, '-');
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Skip rare names group
      final name = row[nameColumnIndex] as String;
      if (name == rareNamesFieldName) return;

      // Deserialize data
      final data = _deserializeData<double>(row[relativeCountColumnIndex]);

      // Compute weighted sum
      const t0 = 2021;
      const oldestAge = 100;
      double weightedSum = 0;
      data.forEach((year, relativeCount) {
        final yearInt = int.parse(year);
        double weight = (yearInt - t0 + oldestAge) / oldestAge;  // Weight is 1 for t0, and 0 for t0-oldestAge (linear)
        weight = weight.clamp(0, 1);    // Clamp to 0-1 range
        double weightedCount = relativeCount * weight;
        weightedSum += weightedCount;
      });
      weightedSums[rowIndex] = weightedSum;

      // Update stats
      if (weightedSum < min.$1) min = (weightedSum, name);
      if (weightedSum > max.$1) max = (weightedSum, name);
    },
  );

  // Stats
  print('Weighted sums stats: $min > $max');

  // Compute popularity indicator
  final namesPopularity = <(String, double)>[];
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      final weightedSum = weightedSums[rowIndex];
      if (weightedSum == null) return;

      // Compute popularity
      double popularity = (weightedSum - min.$1) / (max.$1 - min.$1);    // Normalize to 0-1 range
      popularity = popularity.roundToDecimals(2);   // Round to 2 decimals to reduce serialized file size

      // Update stats
      namesPopularity.add((sheet.rows[rowIndex][nameColumnIndex] as String, popularity));

      // Update sheet
      spreadsheet.updateCell(databaseSheetName, popularityColumnIndex, rowIndex, popularity);
    },
  );

  // Top 10 names
  namesPopularity.sort((a, b) => b.$2.compareTo(a.$2));
  print('Top 10 names: ${namesPopularity.take(10).map((e) => '${e.$1} (${e.$2})').join(', ')}');
}

void countNamesPerGroup(SpreadsheetDecoder spreadsheet) {
  print('Count names per group');
  List<(String, int)> namesPerGroup = [];
  _computeEachGroup(
    spreadsheet,
    (groupHeaderRowIndex, namesRows) {
      namesPerGroup.add((namesRows.first[nameColumnIndex] as String, namesRows.length));
    },
  );
  namesPerGroup.sort((a, b) => b.$2.compareTo(a.$2));
  print('Groups with more than 8 names: ${namesPerGroup.where((e) => e.$2 >= 8).map((e) => '${e.$1} (${e.$2})').join(', ')}');
}

void computeNameLengthStats(spreadsheet) {
  print('Compute name length stats');
  int min = 1000;
  int max = -1;
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Get name
      final name = row[nameColumnIndex] as String;

      // Compute data
      if (name.length < min) min = name.length;
      if (name.length > max) max = name.length;
    },
  );
  print('Name length stats: $min > $max');
}

void addSaints(spreadsheet) {
  print('Add saints');
  // Read saints file
  final saintsSheet = spreadsheet.tables['Saints']!;

  // Convert to list
  final saints = <String, List<DateTime>>{};
  for (int r = 0; r < saintsSheet.rows.length; r++) {
    // Get data
    final row = saintsSheet.rows[r];
    final name = row[0] as String;
    final date = DateTime.parse(row[1] as String);

    // Add to list
    final dates = saints.putIfAbsent(name, () => []);
    dates.add(date);
  }

  // Add saints to database
  _computeEachName(
    spreadsheet,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];

      // Get name
      final name = row[nameColumnIndex] as String;

      // Get saint
      final dates = saints[name];
      if (dates == null) return;

      // Add saints
      spreadsheet.updateCell(databaseSheetName, saintsColumnIndex, rowIndex, dates.map((e) => '${e.day}-${e.month}').join(','));
    },
  );
}

(File, SpreadsheetDecoder) _readSpreadsheetFile(String filepath) {
  final file = File(filepath);
  final bytes = file.readAsBytesSync();
  return (file, SpreadsheetDecoder.decodeBytes(bytes, update: true));
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

Map<String, T> _deserializeData<T extends num>(String dataRaw) => (jsonDecode(dataRaw) as Map<String, dynamic>).cast<String, T>();
