// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/utils/extensions_base.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Pastèque-Match data preparation script
/// A Dart script that takes a ODS file as input, and make some calculation to prepare data.
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
  _computeTotalCount(spreadsheet, sheetName);

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

void _computeTotalCount(SpreadsheetDecoder spreadsheet, String sheetName) {
  print('Compute total count');

  // Get sheet
  final sheet = spreadsheet.tables[sheetName]!;

  // Compute total count for each name
  int lastPrintedProgress = 0;
  for (int r = 1; r < sheet.rows.length; r++) {   // Ignore header
    final progress = (r / sheet.rows.length * 100).toInt();
    if (lastPrintedProgress != progress) print('Progress: ${lastPrintedProgress = progress}%');

    // Get data
    final row = sheet.rows[r];
    final dataRaw = row[3];
    if (dataRaw == null) continue;

    // Deserialize
    final data = (jsonDecode(dataRaw) as Map<String, dynamic>).cast<String, int>();

    // Compute total count
    final totalCount = data.values.reduce((value, element) => value + element);

    // Update sheet
    spreadsheet.updateCell(sheetName, 4, r, totalCount);
  }
}
