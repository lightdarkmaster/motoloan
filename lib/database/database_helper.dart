import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/motorcycle_loan.dart';
import '../models/loan_payment.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'motoloan.db'),
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE motorcycle_loans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            motorcycle_name TEXT NOT NULL,
            brand TEXT NOT NULL,
            total_price_centavos INTEGER NOT NULL,
            down_payment_centavos INTEGER NOT NULL,
            monthly_payment_centavos INTEGER NOT NULL,
            duration_months INTEGER NOT NULL,
            start_date TEXT NOT NULL,
            due_day INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE loan_payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            loan_id INTEGER NOT NULL,
            amount_centavos INTEGER NOT NULL CHECK(amount_centavos > 0),
            payment_date TEXT NOT NULL,
            payment_month TEXT NOT NULL,
            reference_number TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (loan_id) REFERENCES motorcycle_loans(id) ON DELETE CASCADE,
            UNIQUE(loan_id, payment_month)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<MotorcycleLoan?> getLoan() async {
    final db = await database;
    final rows = await db.query('motorcycle_loans', orderBy: 'id DESC', limit: 1);
    return rows.isEmpty ? null : MotorcycleLoan.fromMap(rows.first);
  }

  Future<int> saveLoan(MotorcycleLoan loan) async {
    final db = await database;
    if (loan.totalPriceCentavos <= 0 ||
        loan.downPaymentCentavos < 0 ||
        loan.downPaymentCentavos >= loan.totalPriceCentavos ||
        loan.monthlyPaymentCentavos <= 0 ||
        loan.durationMonths <= 0 ||
        loan.dueDay < 1 || loan.dueDay > 28) {
      throw Exception('Please check the loan details. Due day must be between 1 and 28.');
    }
    return db.transaction((txn) async {
      final existing = await txn.query('motorcycle_loans', limit: 1);
      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        await txn.update('motorcycle_loans', loan.toMap()..remove('id'), where: 'id = ?', whereArgs: [id]);
        return id;
      }
      return txn.insert('motorcycle_loans', loan.toMap()..remove('id'));
    });
  }

  Future<List<LoanPayment>> getPayments(int loanId) async {
    final db = await database;
    final rows = await db.query('loan_payments', where: 'loan_id = ?', whereArgs: [loanId], orderBy: 'payment_date DESC, id DESC');
    return rows.map(LoanPayment.fromMap).toList();
  }

  Future<int> totalPaid(int loanId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount_centavos), 0) AS total FROM loan_payments WHERE loan_id = ?',
      [loanId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> remainingBalance(MotorcycleLoan loan) async {
    final paid = await totalPaid(loan.id!);
    final remaining = loan.loanAmountCentavos - paid;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> savePayment(LoanPayment payment, {int? editingId}) async {
    final db = await database;
    await db.transaction((txn) async {
      final loanRows = await txn.query('motorcycle_loans', where: 'id = ?', whereArgs: [payment.loanId]);
      if (loanRows.isEmpty) throw Exception('Loan not found.');
      final loan = MotorcycleLoan.fromMap(loanRows.first);
      final currentPaidRows = await txn.rawQuery(
        'SELECT COALESCE(SUM(amount_centavos), 0) AS total FROM loan_payments WHERE loan_id = ? AND id != ?',
        [payment.loanId, editingId ?? -1],
      );
      final alreadyPaid = (currentPaidRows.first['total'] as int?) ?? 0;
      if (payment.amountCentavos <= 0) throw Exception('Payment must be greater than zero.');
      if (alreadyPaid + payment.amountCentavos > loan.loanAmountCentavos) {
        throw Exception('Payment exceeds the remaining loan balance.');
      }
      try {
        if (editingId == null) {
          await txn.insert('loan_payments', payment.toMap()..remove('id'));
        } else {
          await txn.update('loan_payments', payment.toMap()..remove('id'), where: 'id = ?', whereArgs: [editingId]);
        }
      } on DatabaseException catch (e) {
        if (e.isUniqueConstraintError()) {
          throw Exception('A payment for ${payment.paymentMonth} is already recorded.');
        }
        rethrow;
      }
    });
  }

  Future<void> deletePayment(int paymentId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('loan_payments', where: 'id = ?', whereArgs: [paymentId]);
    });
  }
}
