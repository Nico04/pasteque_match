import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';

class PmQrCodeWidget extends StatelessWidget {
  const PmQrCodeWidget(this.qrCode, {super.key});

  final String qrCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: PlatformAiBarcodeCreatorWidget(
        creatorController: CreatorController(),   // Mandatory, but not used.
        initialValue: qrCode,
      ),
    );
  }
}
