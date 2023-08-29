import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class NamesService {
  static const _dbFilePath = 'assets/names.xlsx';

  static final instance = NamesService();

  late List<NameGroup> _names;
  List<NameGroup> get names => _names;

  Future<void> load() async {
    final stopwatch = Stopwatch()..start();

    // Load file
    final bytes = await rootBundle.load(_dbFilePath);
    debugPrint('[NamesService] file loaded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();

    // Decode
    final spreadsheet = SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
    debugPrint('[NamesService] file decoded ${stopwatch.elapsedMilliseconds}ms'); stopwatch.reset();

    // Read headers
    final sheet = spreadsheet.tables['BDD']!;
    final headersRow = sheet.rows.first;
    final headersMap = {
      for (var i = 0; i < headersRow.length; i++)
        headersRow[i].toString(): i
    };

    // Build data
    _names = [];
    NameGroup? currentGroup;
    for (final row in sheet.rows.skip(1)) {
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
    debugPrint('[NamesService] data built in ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('[NamesService] database loaded');
  }
}
