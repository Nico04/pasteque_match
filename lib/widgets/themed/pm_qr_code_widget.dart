import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PmQrCodeWidget extends StatelessWidget {
  const PmQrCodeWidget(this.qrCode, {super.key});

  final String qrCode;

  @override
  Widget build(BuildContext context) {
    return PrettyQrView.data(
      data: qrCode,
      decoration: const PrettyQrDecoration(
        quietZone: PrettyQrQuietZone.standart,
      ),
    );
  }
}
