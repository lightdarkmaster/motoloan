class MotorcycleLoan {
  final int? id;
  final String motorcycleName;
  final String brand;
  final int totalPriceCentavos;
  final int downPaymentCentavos;
  final int monthlyPaymentCentavos;
  final int durationMonths;
  final String startDate;
  final int dueDay;
  final String createdAt;

  const MotorcycleLoan({
    this.id,
    required this.motorcycleName,
    required this.brand,
    required this.totalPriceCentavos,
    required this.downPaymentCentavos,
    required this.monthlyPaymentCentavos,
    required this.durationMonths,
    required this.startDate,
    required this.dueDay,
    required this.createdAt,
  });

  int get loanAmountCentavos => totalPriceCentavos - downPaymentCentavos;

  Map<String, Object?> toMap() => {
    'id': id,
    'motorcycle_name': motorcycleName,
    'brand': brand,
    'total_price_centavos': totalPriceCentavos,
    'down_payment_centavos': downPaymentCentavos,
    'monthly_payment_centavos': monthlyPaymentCentavos,
    'duration_months': durationMonths,
    'start_date': startDate,
    'due_day': dueDay,
    'created_at': createdAt,
  };

  factory MotorcycleLoan.fromMap(Map<String, Object?> map) => MotorcycleLoan(
    id: map['id'] as int,
    motorcycleName: map['motorcycle_name'] as String,
    brand: map['brand'] as String,
    totalPriceCentavos: map['total_price_centavos'] as int,
    downPaymentCentavos: map['down_payment_centavos'] as int,
    monthlyPaymentCentavos: map['monthly_payment_centavos'] as int,
    durationMonths: map['duration_months'] as int,
    startDate: map['start_date'] as String,
    dueDay: map['due_day'] as int,
    createdAt: map['created_at'] as String,
  );
}
