import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:serial_csv/serial_csv.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class NamesService {
  static const _dbFilePath = 'assets/names.xlsx';

  static final instance = NamesService();

  late List<NameGroup> _names;
  List<NameGroup> get names => _names;

  /// Load the local database file into memory.
  ///
  /// Because database is quite big, several methods have been tested.
  /// Loading file from assets is quite fast (around 50ms), but decoding might take a while.
  /// 1. XLSX file using spreadsheet_decoder v2.2.0 : 5224ms to decode
  /// 2. ODS file using spreadsheet_decoder v2.2.0 : longer than XLSX
  /// 3. CSV file using csv v5.0.1 : 471ms to decode string + 1292ms to decode CSV = 1763ms
  /// 4. CSV file using fast_csv v0.1.44 : 431ms to decode string + 466ms to decode CSV = 897ms
  /// 4a.Zipped CSV file using fast_csv v0.1.44 & archive v3.3.7 : 22ms to load zip + 14ms to decode zip + 817ms to decode string + 465ms to decode CSV = 1318ms
  /// 5. CSV file using serial_csv v0.4.0 : 417ms to decode string + 3124ms to decode CSV = 3541ms
  ///
  /// Conclusions:
  /// - CSV is the fastest format to decode
  /// - fast_csv is the fastest CSV decoder
  /// - serial_csv is supposed to be the fastest CSV decoder, but it's not. And it's much more strict (double quote string is pain)
  /// - Zipping CSV file reduce file size by 3 but decoding is longer. So it might be interesting to ship zipped file, but unzip file in cache folder once.
  Future<void> load() async {
    final stopwatch = Stopwatch()..start();

    // Load file
/*
    final bytes = await rootBundle.load(_dbFilePath);
    debugPrint('[NamesService] file loaded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();   // file loaded in 56ms
*/
/*
    final bytes = await rootBundle.load('assets/names.ods');
    debugPrint('[NamesService] file loaded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();   // Worse than XLSX
*/

/*
    final csvRaw = await rootBundle.loadString('assets/names.csv', cache: false);
    debugPrint('[NamesService] CSV loaded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();      // CSV loaded in 431ms
    final rows = fast_csv.parse(csvRaw);
    debugPrint('[NamesService] CSV decoded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();      // CSV decoded in 466ms
*/


    final zipBytes = await rootBundle.load('assets/names.zip');
    debugPrint('[NamesService] zip loaded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();    // zip loaded in 22ms
    final zip = ZipDecoder().decodeBytes(zipBytes.buffer.asUint8List());
    debugPrint('[NamesService] zip decoded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();   // zip decoded in 14ms
    final csvRaw = utf8.decode(zip.first.content);
    debugPrint('[NamesService] CSV decoded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();   // CSV decoded in 817ms
    final rows = fast_csv.parse(csvRaw);
    debugPrint('[NamesService] CSV converted in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset(); // CSV converted 465ms



/*
    final csvRaw = await rootBundle.loadString('assets/names.csv', cache: false);
    debugPrint('[NamesService] CSV loaded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();      // CSV loaded in 471ms
    final rows = const CsvToListConverter().convert(csvRaw);
    debugPrint('[NamesService] CSV decoded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();      // CSV decoded in 1292ms
*/

/*


    final csvRaw = await rootBundle.loadString('assets/names2.csv', cache: false);
    debugPrint('[NamesService] CSV loaded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();      // CSV loaded 417ms
    final rows = SerialCsv.decode(csvRaw);
    debugPrint('[NamesService] CSV decoded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();     // CSV decoded 3124ms
*/


/*
    final zipBytes = await rootBundle.load('assets/names.zip');
    debugPrint('[NamesService] zip loaded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();
    final zip = ZipDecoder().decodeBytes(zipBytes.buffer.asUint8List());
    debugPrint('[NamesService] zip decoded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();
    final csvRaw = utf8.decode(zip.first.content);
    debugPrint('[NamesService] CSV decoded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();
    final rows = const CsvToListConverter().convert(csvRaw);
    debugPrint('[NamesService] CSV converted ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();
*/




    /*
    // Decode
    final spreadsheet = SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
    debugPrint('[NamesService] file decoded in ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();   // file decoded in 5224ms
    final sheet = spreadsheet.tables['BDD']!;
    final rows = sheet.rows;
    */



    // Read headers
    final headersRow = rows.first;
    final headersMap = {
      for (var i = 0; i < headersRow.length; i++)
        headersRow[i].toString(): i
    };

    // Build data
    _names = [];
    NameGroup? currentGroup;
    for (final row in rows.skip(1)) {
      final groupId = row[headersMap['groupId']!] as String?;

      // Skip special rows
      if (groupId == '_prenoms_rares') continue;

      // It's a group
      if (!isStringNullOrEmpty(groupId)) {
        currentGroup = NameGroup.fromStrings(
          id: groupId!,
          epicene: row[headersMap['epicene']!],
        );
        _names.add(currentGroup);
      }

      // It's a name
      else if (currentGroup != null) {
        final name = Name.fromStrings(
          name: row[headersMap['name']!],
          gender: row[headersMap['gender']!],
          stats: row[headersMap['count']!],
        );
        currentGroup.names.add(name);
      }
    }
    debugPrint('[NamesService] data built in ${stopwatch.elapsedMilliseconds}ms');    // data built in 249ms
    debugPrint('[NamesService] database loaded');
  }
}
