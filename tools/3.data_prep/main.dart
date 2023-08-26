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
  final bytes = await File(inputFilePath).readAsBytes();
  final tables = SpreadsheetDecoder.decodeBytes(bytes).tables;

  // Open BDD table
  final bddTable = tables['BDD']!;



  // Exit program
  exit(0);
}
