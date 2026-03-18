class Payment {
  final int id;
  final String paymentReference;
  final int invoiceId;
  final String amount;
  final String paymentMethod;
  final String paymentDate;
  final String transactionReference;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final int createdById;

  Payment({
    required this.id,
    required this.paymentReference,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.transactionReference,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentReference: json['payment_reference'] ?? '',
      invoiceId: json['invoice_id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      paymentMethod: json['payment_method'] ?? '',
      paymentDate: json['payment_date'] ?? '',
      transactionReference: json['transaction_reference'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdById: json['created_by_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
      'transaction_reference': transactionReference,
      'notes': notes,
      'created_by_id': createdById,
    };
  }
}
