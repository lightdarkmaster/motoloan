import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/motorcycle_loan.dart';
import '../models/loan_payment.dart';
import '../utils/money.dart';

import 'payment_form_screen.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final MotorcycleLoan loan;

  const PaymentHistoryScreen({super.key, required this.loan});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<LoanPayment> payments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await DatabaseHelper.instance.getPayments(widget.loan.id!);

    if (mounted) {
      setState(() {
        payments = result;
        loading = false;
      });
    }
  }

  Future<void> edit(LoanPayment p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFormScreen(loan: widget.loan, existing: p),
      ),
    );

    load();
  }

  Future<void> delete(LoanPayment p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete payment?'),
        content: Text(
          'Delete ${formatPeso(p.amountCentavos)} for ${monthLabel(p.paymentMonth)}? The remaining balance will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (yes == true) {
      await DatabaseHelper.instance.deletePayment(p.id!);
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment history')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? const Center(child: Text('No payments recorded yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final p = payments[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.check,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),

                      title: Text(
                        formatPeso(p.amountCentavos),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      subtitle: Text(
                        '${monthLabel(p.paymentMonth)}\n'
                        'Paid on ${p.paymentDate}'
                        '${p.referenceNumber == null ? '' : '\nRef: ${p.referenceNumber}'}',
                      ),

                      isThreeLine: true,

                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            edit(p);
                          } else {
                            delete(p);
                          }
                        },

                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
