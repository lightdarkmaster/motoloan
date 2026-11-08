import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/motorcycle_loan.dart';
import '../models/loan_payment.dart';
import '../utils/money.dart';
import '../app_theme_controller.dart';

import 'loan_form_screen.dart';
import 'payment_form_screen.dart';
import 'payment_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.themeController});
  final AppThemeController themeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  Color get accentColor => Theme.of(context).colorScheme.primary;

  MotorcycleLoan? loan;
  int paid = 0;
  int remaining = 0;
  List<LoanPayment> recent = [];
  bool loading = true;

  int get remainingMonths =>
      loan == null || remaining <= 0 || loan!.monthlyPaymentCentavos <= 0
      ? 0
      : (remaining + loan!.monthlyPaymentCentavos - 1) ~/
            loan!.monthlyPaymentCentavos;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => loading = true);

    final found = await db.getLoan();

    if (found != null) {
      final p = await db.totalPaid(found.id!);
      final r = await db.remainingBalance(found);
      final payments = await db.getPayments(found.id!);

      if (!mounted) return;

      setState(() {
        loan = found;
        paid = p;
        remaining = r;
        recent = payments.take(3).toList();
        loading = false;
      });
    } else if (mounted) {
      setState(() {
        loan = null;
        paid = 0;
        remaining = 0;
        recent = [];
        loading = false;
      });
    }
  }

  Future<void> openLoanForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoanFormScreen(existing: loan)),
    );

    refresh();
  }

  Future<void> openPaymentForm() async {
    if (loan == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentFormScreen(loan: loan!)),
    );

    refresh();
  }

  Future<void> openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(controller: widget.themeController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = loan;

    final progress = l == null || l.loanAmountCentavos == 0
        ? 0.0
        : (paid / l.loanAmountCentavos).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.two_wheeler,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'MotoLoan',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),

          IconButton(
            onPressed: openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  if (l == null) ...[
                    const SizedBox(height: 55),

                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 76,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Start tracking your motorcycle loan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Add your motorcycle price, down payment, and monthly installment to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 22),

                    FilledButton.icon(
                      onPressed: openLoanForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Add motorcycle loan'),
                    ),
                  ] else ...[
                    _balanceCard(l, progress),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Total paid',
                            formatPeso(paid),
                            Icons.check_circle_outline,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _statCard(
                            'Monthly payment',
                            formatPeso(l.monthlyPaymentCentavos),
                            Icons.calendar_month,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Motorcycle details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                TextButton(
                                  onPressed: openLoanForm,
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),

                            _detail(
                              'Motorcycle',
                              '${l.brand} ${l.motorcycleName}',
                            ),

                            _detail(
                              'Motorcycle price',
                              formatPeso(l.totalPriceCentavos),
                            ),

                            _detail(
                              'Down payment',
                              formatPeso(l.downPaymentCentavos),
                            ),

                            _detail(
                              'Original loan amount',
                              formatPeso(l.loanAmountCentavos),
                            ),

                            _detail(
                              'Loan duration',
                              '${l.durationMonths} months',
                            ),
                            _detail(
                              'Remaining months',
                              '$remainingMonths months',
                            ),

                            _detail(
                              'Due day',
                              'Every ${l.dueDay}${_ordinal(l.dueDay)} of the month',
                            ),

                            _detail(
                              'Start date',
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(DateTime.parse(l.startDate)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FilledButton.icon(
                      onPressed: remaining == 0 ? null : openPaymentForm,
                      icon: const Icon(Icons.add_card),
                      label: Text(
                        remaining == 0
                            ? 'Loan fully paid'
                            : 'Record monthly payment',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent payments',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentHistoryScreen(loan: l),
                              ),
                            );

                            refresh();
                          },
                          child: const Text('View all'),
                        ),
                      ],
                    ),

                    if (recent.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('No payments recorded yet.'),
                        ),
                      )
                    else
                      ...recent.map(
                        (p) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.check,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),

                            title: Text(
                              formatPeso(p.amountCentavos),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              '${monthLabel(p.paymentMonth)} • ${p.paymentDate}',
                            ),

                            trailing: const Icon(Icons.chevron_right),

                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentHistoryScreen(loan: l),
                                ),
                              );

                              refresh();
                            },
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),

      floatingActionButton: l == null
          ? null
          : FloatingActionButton(
              onPressed: openPaymentForm,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _balanceCard(MotorcycleLoan l, double progress) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 1),
            accentColor.withValues(alpha: 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REMAINING BALANCE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.1,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            formatPeso(remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loan progress',
                style: TextStyle(color: Colors.white),
              ),

              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${l.brand} ${l.motorcycleName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),

            const SizedBox(height: 10),

            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return 'th';

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
