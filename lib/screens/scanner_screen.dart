import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../utils/barcode_rules.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handled = false;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _showResult(String code) {
    final valid = barcodeIsValid(code);
    final name = productNameForBarcode(code);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Scan result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barcode: $code'),
              const SizedBox(height: 8),
              Text('Product: $name'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    valid ? '✅ Valid' : '❌ Invalid',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: valid ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Rule: last digit even → Valid; odd → Invalid.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Scan again'),
            ),
          ],
        );
      },
    ).then((_) {
      if (!mounted) return;
      setState(() => _handled = false);
      _camera.start();
    });
  }

  void _onManualSubmit(String text) {
    final code = text.trim();
    if (code.isEmpty) return;
    _showResult(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode QC'),
        actions: [
          IconButton(
            tooltip: 'Toggle torch',
            onPressed: () => _camera.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: _camera,
              builder: (context, state, child) {
                final on = state.torchState == TorchState.on;
                return Icon(on ? Icons.flash_on : Icons.flash_off);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: MobileScanner(
                controller: _camera,
                onDetect: (capture) {
                  if (_handled) return;
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;
                  final raw = barcodes.first.rawValue;
                  if (raw == null || raw.isEmpty) return;
                  setState(() => _handled = true);
                  _camera.stop();
                  _showResult(raw);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Simulator / manual check',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _ManualBarcodeField(onSubmit: _onManualSubmit),
                const SizedBox(height: 8),
                Text(
                  'Try codes ending in 0,2,4,6,8 (valid) vs 1,3,5,7,9 (invalid).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualBarcodeField extends StatefulWidget {
  const _ManualBarcodeField({required this.onSubmit});

  final void Function(String) onSubmit;

  @override
  State<_ManualBarcodeField> createState() => _ManualBarcodeFieldState();
}

class _ManualBarcodeFieldState extends State<_ManualBarcodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter barcode',
              border: OutlineInputBorder(),
            ),
            onSubmitted: widget.onSubmit,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => widget.onSubmit(_controller.text),
          child: const Text('Check'),
        ),
      ],
    );
  }
}
