import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/motorcycle_loan.dart';
import '../models/loan_payment.dart';
import '../utils/money.dart';

class PaymentFormScreen extends StatefulWidget {
  final MotorcycleLoan loan;
  final LoanPayment? existing;

  const PaymentFormScreen({super.key, required this.loan, this.existing});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final reference = TextEditingController();
  final notes = TextEditingController();

  DateTime paymentDate = DateTime.now();
  DateTime paymentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool saving = false;

  @override
  void initState() {
    super.initState();

    final p = widget.existing;

    if (p != null) {
      amount.text = (p.amountCentavos / 100).toStringAsFixed(2);
      reference.text = p.referenceNumber ?? '';
      notes.text = p.notes ?? '';
      paymentDate = DateTime.parse(p.paymentDate);

      final parts = p.paymentMonth.split('-');
      paymentMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
  }

  @override
  void dispose() {
    amount.dispose();
    reference.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (d != null) {
      setState(() {
        paymentDate = d;
        paymentMonth = DateTime(d.year, d.month);
      });
    }
  }

  Future<void> pickMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: paymentMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Choose a date in the billing month',
    );

    if (selected != null) {
      setState(() {
        paymentMonth = DateTime(selected.year, selected.month);
      });
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      setState(() => saving = true);

      final payment = LoanPayment(
        id: widget.existing?.id,
        loanId: widget.loan.id!,
        amountCentavos: parsePesos(amount.text),
        paymentDate: paymentDate.toIso8601String().substring(0, 10),
        paymentMonth:
            '${paymentMonth.year}-${paymentMonth.month.toString().padLeft(2, '0')}',
        referenceNumber: reference.text.trim().isEmpty
            ? null
            : reference.text.trim(),
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
        createdAt:
            widget.existing?.createdAt ?? DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.savePayment(
        payment,
        editingId: widget.existing?.id,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Record payment' : 'Edit payment',
        ),
      ),

      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motorcycle loan',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${widget.loan.brand} ${widget.loan.motorcycleName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Monthly installment: ${formatPeso(widget.loan.monthlyPaymentCentavos)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Payment amount (₱)',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter the payment amount.';
                }

                try {
                  if (parsePesos(v) <= 0) {
                    return 'Amount must be greater than zero.';
                  }
                } catch (_) {
                  return 'Enter a valid amount.';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                title: const Text('Payment date'),
                subtitle: Text(paymentDate.toIso8601String().substring(0, 10)),
                trailing: const Icon(Icons.calendar_month),
                onTap: pickDate,
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('Billing month'),
                subtitle: Text(
                  monthLabel(
                    '${paymentMonth.year}-${paymentMonth.month.toString().padLeft(2, '0')}',
                  ),
                ),
                trailing: const Icon(Icons.date_range),
                onTap: pickMonth,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: reference,
              decoration: const InputDecoration(
                labelText: 'Reference number (optional)',
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),

            const SizedBox(height: 22),

            FilledButton(
              onPressed: saving ? null : save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(saving ? 'Saving...' : 'Save payment'),
            ),

            const SizedBox(height: 8),

            Text(
              'Saving a payment updates the remaining balance automatically. This records a payment locally; it does not transfer money.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
