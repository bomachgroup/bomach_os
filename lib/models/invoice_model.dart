class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? clientAddress;

  // Service/Order reference
  final String? serviceType; // 'Real Estate', 'Land Survey', 'Property Management', etc.
  final String? serviceId; // Reference to service order
  final String? projectId; // Reference to project if applicable

  // Financial details
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double totalAmount;
  final String currency;

  // Dates
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;

  // Status and workflow
  final InvoiceStatus status;
  final PaymentStatus paymentStatus;

  // Payment tracking
  final List<Payment> payments;
  final double amountPaid;
  final double balance;

  // Additional info
  final String? notes;
  final String? termsAndConditions;
  final List<String> attachments;

  // Audit fields
  final String createdBy;
  final DateTime createdDate;
  final String? lastModifiedBy;
  final DateTime? lastModifiedDate;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.serviceType,
    this.serviceId,
    this.projectId,
    required this.items,
    required this.subtotal,
    this.taxRate = 7.5,
    required this.taxAmount,
    this.discount = 0,
    required this.totalAmount,
    this.currency = '₦',
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    this.status = InvoiceStatus.draft,
    this.paymentStatus = PaymentStatus.unpaid,
    this.payments = const [],
    required this.amountPaid,
    required this.balance,
    this.notes,
    this.termsAndConditions,
    this.attachments = const [],
    required this.createdBy,
    required this.createdDate,
    this.lastModifiedBy,
    this.lastModifiedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
      'serviceType': serviceType,
      'serviceId': serviceId,
      'projectId': projectId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discount': discount,
      'totalAmount': totalAmount,
      'currency': currency,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'payments': payments.map((p) => p.toJson()).toList(),
      'amountPaid': amountPaid,
      'balance': balance,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'attachments': attachments,
      'createdBy': createdBy,
      'createdDate': createdDate.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      clientAddress: json['clientAddress'],
      serviceType: json['serviceType'],
      serviceId: json['serviceId'],
      projectId: json['projectId'],
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      taxRate: json['taxRate'] ?? 7.5,
      taxAmount: json['taxAmount'],
      discount: json['discount'] ?? 0,
      totalAmount: json['totalAmount'],
      currency: json['currency'] ?? '₦',
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: InvoiceStatus.values.firstWhere((e) => e.name == json['status']),
      paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == json['paymentStatus']),
      payments: (json['payments'] as List?)
          ?.map((p) => Payment.fromJson(p))
          .toList() ?? [],
      amountPaid: json['amountPaid'],
      balance: json['balance'],
      notes: json['notes'],
      termsAndConditions: json['termsAndConditions'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdBy: json['createdBy'],
      createdDate: DateTime.parse(json['createdDate']),
      lastModifiedBy: json['lastModifiedBy'],
      lastModifiedDate: json['lastModifiedDate'] != null
          ? DateTime.parse(json['lastModifiedDate'])
          : null,
    );
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? serviceType,
    String? serviceId,
    String? projectId,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    double? totalAmount,
    String? currency,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidDate,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    List<Payment>? payments,
    double? amountPaid,
    double? balance,
    String? notes,
    String? termsAndConditions,
    List<String>? attachments,
    String? createdBy,
    DateTime? createdDate,
    String? lastModifiedBy,
    DateTime? lastModifiedDate,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      serviceType: serviceType ?? this.serviceType,
      serviceId: serviceId ?? this.serviceId,
      projectId: projectId ?? this.projectId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      payments: payments ?? this.payments,
      amountPaid: amountPaid ?? this.amountPaid,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      attachments: attachments ?? this.attachments,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;
  final String? unit; // 'sqm', 'plot', 'hour', etc.

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
      'unit': unit,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      amount: json['amount'],
      unit: json['unit'],
    );
  }
}

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final PaymentApprovalStatus approvalStatus;
  final String? transactionReference;
  final String? bankName;
  final String? accountNumber;
  final String? depositorName;
  final String? receiptNumber;
  final List<String> proofOfPayment; // File paths/URLs
  final String? notes;

  // Approval workflow
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? rejectedBy;
  final DateTime? rejectedDate;
  final String? rejectionReason;

  // Audit
  final String createdBy;
  final DateTime createdDate;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.approvalStatus = PaymentApprovalStatus.pending,
    this.transactionReference,
    this.bankName,
    this.accountNumber,
    this.depositorName,
    this.receiptNumber,
    this.proofOfPayment = const [],
    this.notes,
    this.approvedBy,
    this.approvedDate,
    this.rejectedBy,
    this.rejectedDate,
    this.rejectionReason,
    required this.createdBy,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'method': method.name,
      'approvalStatus': approvalStatus.name,
      'transactionReference': transactionReference,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'depositorName': depositorName,
      'receiptNumber': receiptNumber,
      'proofOfPayment': proofOfPayment,
      'notes': notes,
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedDate': rejectedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'createdBy': createdBy,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      invoiceId: json['invoiceId'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      method: PaymentMethod.values.firstWhere((e) => e.name == json['method']),
      approvalStatus: PaymentApprovalStatus.values.firstWhere(
        (e) => e.name == json['approvalStatus'],
        orElse: () => PaymentApprovalStatus.pending,
      ),
      transactionReference: json['transactionReference'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      depositorName: json['depositorName'],
      receiptNumber: json['receiptNumber'],
      proofOfPayment: List<String>.from(json['proofOfPayment'] ?? []),
      notes: json['notes'],
      approvedBy: json['approvedBy'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      rejectedBy: json['rejectedBy'],
      rejectedDate: json['rejectedDate'] != null
          ? DateTime.parse(json['rejectedDate'])
          : null,
      rejectionReason: json['rejectionReason'],
      createdBy: json['createdBy'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Payment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? method,
    PaymentApprovalStatus? approvalStatus,
    String? transactionReference,
    String? bankName,
    String? accountNumber,
    String? depositorName,
    String? receiptNumber,
    List<String>? proofOfPayment,
    String? notes,
    String? approvedBy,
    DateTime? approvedDate,
    String? rejectedBy,
    DateTime? rejectedDate,
    String? rejectionReason,
    String? createdBy,
    DateTime? createdDate,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      transactionReference: transactionReference ?? this.transactionReference,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      depositorName: depositorName ?? this.depositorName,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      proofOfPayment: proofOfPayment ?? this.proofOfPayment,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  overdue,
  cancelled,
  void_,
}

enum PaymentStatus {
  unpaid,
  partiallyPaid,
  paid,
  refunded,
  cancelled,
}

enum PaymentMethod {
  cash,
  bankTransfer,
  cheque,
  card,
  mobileWallet,
  other,
}

enum PaymentApprovalStatus {
  pending,
  approved,
  rejected,
  underReview,
}
