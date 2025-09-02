import 'package:pasteque_match/utils/_utils.dart';

class ScanResult {
  const ScanResult(this.rawValue);

  static const _qrCodeHeader = 'PM##';

  static String buildCode(String userId) => _qrCodeHeader + userId;

  final String rawValue;

  bool get isValid => rawValue.startsWith(_qrCodeHeader);

  String? get userId => isValid ? rawValue.substringSafe(startIndex: _qrCodeHeader.length) : null;
}
