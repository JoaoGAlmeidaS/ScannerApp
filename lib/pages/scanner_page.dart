import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner_app/pages/leitura_page.dart';


class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final codigoLido = capture.barcodes.first.rawValue;

    if (codigoLido != null) {
      _isProcessing = true;

      //Parte de Scanner com a camera do celular
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => ResultPage(codigoLido: codigoLido),
      //   ),
      // ).then((_) => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeituraPage()),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}