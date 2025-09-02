import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'scan_result.page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage(this.type, {super.key});

  final ScanResultPageType type;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(   // Handle camera permissions on its own.
              placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
              overlayBuilder: (context, constraints) => Container(
                width: constraints.maxWidth * 0.7,
                height: constraints.maxWidth * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 10),
                ),
              ),
              onDetectError: reportError,
              onDetect: (result) {
                final barcode = result.barcodes.first.rawValue;
                debugPrint('Barcode found: $barcode');

                // Prevent multiple navigations (onDetect might be called multiple times).
                if (!_navigating) {
                  _navigating = true;
                  navigateTo(
                    context,
                    (_) => ScanResultPage(widget.type, result.barcodes.first.rawValue ?? '-'),
                    removePreviousRoutesAmount: 1, // Exit scanner while displaying result; easier lifecycle handling.
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
