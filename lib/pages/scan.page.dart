import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/_utils.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _BarcodeScanner(
              onResult: (result) => navigateTo(
                context,
                (_) => Text('TODO'),    // TODO
                removePreviousRoutesAmount: 1,    // Easy way to properly stop scanner while on new page
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeScanner extends StatefulWidget {
  const _BarcodeScanner({Key? key, required this.onResult}) : super(key: key);

  final ValueChanged<String> onResult;

  @override
  State<_BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<_BarcodeScanner> {
  bool _isLoading = true;
  late ScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = ScannerController(
      scannerResult: widget.onResult,
      scannerViewCreated: () async {
        // Arbitrary delay needed on iOS, otherwise may throw a MissingPluginException
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          await Future.delayed(const Duration(seconds: 1));
        }

        // Start scanner
        _startScanner();

        // Remove loader
        // Arbitrary delay needed, because scanner doesn't start right away
        await Future.delayed(const Duration(seconds: 1));
        setState((){
          _isLoading = false;
        });
      },
    );
  }

  void _startScanner() {
    _scannerController.startCamera();
    _scannerController.startCameraPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
        PlatformAiBarcodeScannerWidget(
          platformScannerController: _scannerController,
        ),
      ],
    );
  }

  void stopScanner() {
    _scannerController.stopCameraPreview();
    _scannerController.stopCamera();
  }

  @override
  void dispose() {
    stopScanner();
    super.dispose();
  }
}
