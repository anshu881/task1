/// Last digit of the barcode: even → valid (QC pass), odd → invalid.
bool barcodeIsValid(String raw) {
  final code = raw.trim();
  if (code.isEmpty) return false;
  for (var i = code.length - 1; i >= 0; i--) {
    final ch = code.codeUnitAt(i);
    if (ch >= 48 && ch <= 57) {
      return (ch - 48).isEven;
    }
  }
  return false;
}

/// Dummy mapping for demo: deterministic name from code.
String productNameForBarcode(String raw) {
  final code = raw.trim();
  if (code.isEmpty) return 'Unknown product';

  const catalog = <String, String>{
    '8901234567890': 'Premium Widget XL',
    '5901234123457': 'Carton Sealer Tape',
    '4006381333931': 'Bulk Carton — 20 unit',
  };
  if (catalog.containsKey(code)) return catalog[code]!;

  final names = [
    'Line Item Stock A',
    'Line Item Stock B',
    'Line Item Stock C',
    'Warehouse Pallet SKU',
    'Replenishment Pack',
  ];
  final idx = code.hashCode.abs() % names.length;
  return names[idx];
}
