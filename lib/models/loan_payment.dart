class LoanPayment {
  final int? id;
  final int loanId;
  final int amountCentavos;
  final String paymentDate;
  final String paymentMonth;
  final String? referenceNumber;
  final String? notes;
  final String createdAt;

  const LoanPayment({
    this.id,
    required this.loanId,
    required this.amountCentavos,
    required this.paymentDate,
    required this.paymentMonth,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'loan_id': loanId,
    'amount_centavos': amountCentavos,
    'payment_date': paymentDate,
    'payment_month': paymentMonth,
    'reference_number': referenceNumber,
    'notes': notes,
    'created_at': createdAt,
  };

  factory LoanPayment.fromMap(Map<String, Object?> map) => LoanPayment(
    id: map['id'] as int,
    loanId: map['loan_id'] as int,
    amountCentavos: map['amount_centavos'] as int,
    paymentDate: map['payment_date'] as String,
    paymentMonth: map['payment_month'] as String,
    referenceNumber: map['reference_number'] as String?,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
  );
}
