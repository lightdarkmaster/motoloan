import 'package:intl/intl.dart';

final _pesoFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

String formatPeso(int centavos) => _pesoFormat.format(centavos / 100);

int parsePesos(String value) {
  final cleaned = value.replaceAll(',', '').replaceAll('₱', '').trim();
  final amount = double.tryParse(cleaned);
  if (amount == null) throw const FormatException('Enter a valid amount.');
  return (amount * 100).round();
}

String monthLabel(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length != 2) return yyyyMm;
  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat('MMMM yyyy').format(date);
}
