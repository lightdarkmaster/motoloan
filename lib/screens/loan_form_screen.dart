import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/motorcycle_loan.dart';
import '../utils/money.dart';

class LoanFormScreen extends StatefulWidget {
  final MotorcycleLoan? existing;
  const LoanFormScreen({super.key, this.existing});
  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final brand = TextEditingController();
  final price = TextEditingController();
  final down = TextEditingController();
  final monthly = TextEditingController();
  final duration = TextEditingController();
  final dueDay = TextEditingController(text: '15');
  DateTime startDate = DateTime.now();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final l = widget.existing;
    if (l != null) {
      name.text = l.motorcycleName; brand.text = l.brand;
      price.text = (l.totalPriceCentavos / 100).toStringAsFixed(2);
      down.text = (l.downPaymentCentavos / 100).toStringAsFixed(2);
      monthly.text = (l.monthlyPaymentCentavos / 100).toStringAsFixed(2);
      duration.text = l.durationMonths.toString(); dueDay.text = l.dueDay.toString();
      startDate = DateTime.parse(l.startDate);
    }
  }

  @override
  void dispose() {
    name.dispose(); brand.dispose(); price.dispose(); down.dispose(); monthly.dispose(); duration.dispose(); dueDay.dispose();
    super.dispose();
  }

  String? requiredText(String? v) => v == null || v.trim().isEmpty ? 'This field is required.' : null;
  String? validMoney(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required.';
    try { if (parsePesos(v) <= 0) return 'Enter an amount greater than zero.'; } catch (_) { return 'Enter a valid amount.'; }
    return null;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => saving = true);
      final total = parsePesos(price.text);
      final downAmount = down.text.trim().isEmpty ? 0 : parsePesos(down.text);
      if (downAmount >= total) throw Exception('Down payment must be lower than the motorcycle price.');
      final loan = MotorcycleLoan(
        id: widget.existing?.id,
        motorcycleName: name.text.trim(),
        brand: brand.text.trim(),
        totalPriceCentavos: total,
        downPaymentCentavos: downAmount,
        monthlyPaymentCentavos: parsePesos(monthly.text),
        durationMonths: int.parse(duration.text),
        startDate: startDate.toIso8601String().substring(0, 10),
        dueDay: int.parse(dueDay.text),
        createdAt: widget.existing?.createdAt ?? DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.saveLoan(loan);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.existing == null ? 'Add motorcycle loan' : 'Edit motorcycle loan')),
    body: Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Motorcycle information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        TextFormField(controller: brand, decoration: const InputDecoration(labelText: 'Brand (e.g. Suzuki)'), validator: requiredText),
        const SizedBox(height: 12),
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Motorcycle model (e.g. Gixxer SF 155)'), validator: requiredText),
        const SizedBox(height: 20),
        const Text('Loan details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        TextFormField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total motorcycle price (₱)'), validator: validMoney),
        const SizedBox(height: 12),
        TextFormField(controller: down, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Down payment (₱)', helperText: 'Enter 0 if there is no down payment.')),
        const SizedBox(height: 12),
        TextFormField(controller: monthly, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Monthly payment (₱)'), validator: validMoney),
        const SizedBox(height: 12),
        TextFormField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Loan duration (months)'), validator: (v) {
          if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) return 'Enter a valid number of months.';
          return null;
        }),
        const SizedBox(height: 12),
        TextFormField(controller: dueDay, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly due day (1–28)'), validator: (v) {
          final n = int.tryParse(v ?? '');
          if (n == null || n < 1 || n > 28) return 'Enter a day from 1 to 28.';
          return null;
        }),
        const SizedBox(height: 12),
        Card(child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: const Text('Loan start date'),
          subtitle: Text('${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.calendar_month),
          onTap: () async {
            final selected = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (selected != null) setState(() => startDate = selected);
          },
        )),
        const SizedBox(height: 22),
        FilledButton(onPressed: saving ? null : save, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: Text(saving ? 'Saving...' : 'Save loan details')),
      ]),
    ),
  );
}
