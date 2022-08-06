import 'package:pasteque_match/utils/_utils.dart';

class ScanResult {
  static const _qrCodeHeader = 'PM##';

  static String buildCode(String userId) => _qrCodeHeader + userId;

  const ScanResult(this.rawValue);

  final String rawValue;

  bool get isValid => rawValue.startsWith(_qrCodeHeader);

  String? get userId => isValid ? rawValue.substringSafe(startIndex: _qrCodeHeader.length) : null;
}
