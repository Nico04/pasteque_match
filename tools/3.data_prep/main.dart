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
  //_computeTotalCount(spreadsheet, sheetName);

  // Compute hyphenation
  //_computeHyphenation(spreadsheet, sheetName);

  // Sort names in each group by total count + rename group to highest count
  sortAndRenameGroups(spreadsheet, sheetName);

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

bool _askConfirmation(String prompt) {
  print(prompt);
  final response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') return false;
  return true;
}

void computeTotalCount(SpreadsheetDecoder spreadsheet, String sheetName) {
  print('Compute total count');
  _computeEachName(
      spreadsheet,
      sheetName,
      (sheet, rowIndex) {
        // Get data
        final row = sheet.rows[rowIndex];
        final dataRaw = row[3];
        if (dataRaw == null) return;

        // Deserialize
        final data = (jsonDecode(dataRaw) as Map<String, dynamic>).cast<String, int>();

        // Compute total count
        final totalCount = data.values.reduce((value, element) => value + element);

        // Update sheet
        spreadsheet.updateCell(sheetName, 4, rowIndex, totalCount);
      },
  );
}

void computeHyphenation(SpreadsheetDecoder spreadsheet, String sheetName) {
  print('Compute hyphenation');
  const hyphenationChars = ['-', "'"];
  _computeEachName(
    spreadsheet,
    sheetName,
    (sheet, rowIndex) {
      // Get data
      final row = sheet.rows[rowIndex];
      final name = row[1] as String?;
      if (name == null || name.isEmpty) return;

      // Compute
      final bool hyphenated = hyphenationChars.any(name.contains);

      // Update sheet
      spreadsheet.updateCell(sheetName, 5, rowIndex, hyphenated ? true : false);
    },
  );
}

void sortAndRenameGroups(SpreadsheetDecoder spreadsheet, String sheetName) {
  print('Sort and rename groups');
  _computeEachGroup(
    spreadsheet,
    sheetName,
    (groupHeaderRowIndex, namesRows) {
      // Skip groups with only one name
      if (namesRows.length <= 1) return;

      // Sort names by total count
      namesRows.sort((a, b) => (b[4] as num).compareTo(a[4] as num));
      //print('Group ${namesRows.first[1]}');

      // Rename group to highest count
      spreadsheet.updateCell(sheetName, 0, groupHeaderRowIndex, namesRows.first[1]);

      // Save new row order
      for (int r = 0; r < namesRows.length; r++) {
        final row = namesRows[r];
        for (int c = 0; c < row.length; c++) {
          final value = row[c];
          spreadsheet.updateCell(sheetName, c, groupHeaderRowIndex + 1 + r, value ?? '');
        }
      }
    },
  );
}

void _computeEachName(SpreadsheetDecoder spreadsheet, String sheetName, void Function(SpreadsheetTable sheet, int rowIndex) task) {
  // Get sheet
  final sheet = spreadsheet.tables[sheetName]!;

  // Compute total count for each name
  int lastPrintedProgress = 0;
  for (int r = 1; r < sheet.rows.length; r++) {   // Ignore header
    // Ignore group headers
    if (isStringNullOrEmpty(sheet.rows[r][1])) continue;

    // Compute
    task(sheet, r);

    // Progress
    final progress = (r / sheet.rows.length * 100).toInt();
    if (lastPrintedProgress != progress) print('Progress: ${lastPrintedProgress = progress}%');
  }
}

void _computeEachGroup(SpreadsheetDecoder spreadsheet, String sheetName, void Function(int groupHeaderRowIndex, List<List> namesRows) task) {
  // Get sheet
  final sheet = spreadsheet.tables[sheetName]!;

  // Compute total count for each name
  int lastPrintedProgress = 0;
  int groupHeaderRowIndex = 0;
  final groupRows = <List>[];
  for (int r = 1; r < sheet.rows.length + 1; r++) {   // Ignore header
    // Detect group headers
    final row = sheet.rows.elementAtOrNull(r);
    if (row == null || !isStringNullOrEmpty(row[0])) {
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

bool isStringNullOrEmpty(String? s) => s == null || s.isEmpty;
