class PerformanceInvoice {
  final String id;
  final String estateId;
  final String estateName;
  final String? plotId;
  final String? plotNumber;
  final String
      serviceType; // 'Real Estate', 'Land Survey', 'Property Management', 'Estate Management'
  final String
      transactionType; // 'Sale', 'Reservation', 'Payment', 'Commission'
  final double amount;
  final DateTime transactionDate;
  final String? clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String
      paymentMethod; // 'Cash', 'Bank Transfer', 'Card', 'Cheque', 'Installment'
  final String paymentStatus; // 'Paid', 'Pending', 'Partial', 'Failed'
  final double? amountPaid;
  final double? balance;
  final String? invoiceNumber;
  final String? description;
  final String? agentName;
  final double? commissionAmount;
  final double? commissionPercentage;
  final List<String> attachments;
  final DateTime createdDate;
  final DateTime? lastUpdated;

  PerformanceInvoice({
    required this.id,
    required this.estateId,
    required this.estateName,
    this.plotId,
    this.plotNumber,
    this.serviceType = 'Real Estate',
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    this.clientName,
    this.clientPhone,
    this.clientEmail,
    required this.paymentMethod,
    required this.paymentStatus,
    this.amountPaid,
    this.balance,
    this.invoiceNumber,
    this.description,
    this.agentName,
    this.commissionAmount,
    this.commissionPercentage,
    this.attachments = const [],
    required this.createdDate,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estateId': estateId,
      'estateName': estateName,
      'plotId': plotId,
      'plotNumber': plotNumber,
      'serviceType': serviceType,
      'transactionType': transactionType,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'balance': balance,
      'invoiceNumber': invoiceNumber,
      'description': description,
      'agentName': agentName,
      'commissionAmount': commissionAmount,
      'commissionPercentage': commissionPercentage,
      'attachments': attachments,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory PerformanceInvoice.fromJson(Map<String, dynamic> json) {
    return PerformanceInvoice(
      id: json['id'],
      estateId: json['estateId'],
      estateName: json['estateName'],
      plotId: json['plotId'],
      plotNumber: json['plotNumber'],
      serviceType: json['serviceType'] ?? 'Real Estate',
      transactionType: json['transactionType'],
      amount: json['amount'],
      transactionDate: DateTime.parse(json['transactionDate']),
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      clientEmail: json['clientEmail'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      amountPaid: json['amountPaid'],
      balance: json['balance'],
      invoiceNumber: json['invoiceNumber'],
      description: json['description'],
      agentName: json['agentName'],
      commissionAmount: json['commissionAmount'],
      commissionPercentage: json['commissionPercentage'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdDate: DateTime.parse(json['createdDate']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  PerformanceInvoice copyWith({
    String? id,
    String? estateId,
    String? estateName,
    String? plotId,
    String? plotNumber,
    String? serviceType,
    String? transactionType,
    double? amount,
    DateTime? transactionDate,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? paymentMethod,
    String? paymentStatus,
    double? amountPaid,
    double? balance,
    String? invoiceNumber,
    String? description,
    String? agentName,
    double? commissionAmount,
    double? commissionPercentage,
    List<String>? attachments,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) {
    return PerformanceInvoice(
      id: id ?? this.id,
      estateId: estateId ?? this.estateId,
      estateName: estateName ?? this.estateName,
      plotId: plotId ?? this.plotId,
      plotNumber: plotNumber ?? this.plotNumber,
      serviceType: serviceType ?? this.serviceType,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      balance: balance ?? this.balance,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      description: description ?? this.description,
      agentName: agentName ?? this.agentName,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      attachments: attachments ?? this.attachments,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class PerformanceStats {
  final double totalRevenue;
  final double totalPaid;
  final double totalPending;
  final int totalTransactions;
  final int totalSales;
  final int totalReservations;
  final double averageTransactionValue;
  final double totalCommissions;
  final Map<String, double> revenueByEstate;
  final Map<String, int> transactionsByType;
  final Map<String, double> revenueByMonth;

  PerformanceStats({
    required this.totalRevenue,
    required this.totalPaid,
    required this.totalPending,
    required this.totalTransactions,
    required this.totalSales,
    required this.totalReservations,
    required this.averageTransactionValue,
    required this.totalCommissions,
    required this.revenueByEstate,
    required this.transactionsByType,
    required this.revenueByMonth,
  });

  factory PerformanceStats.fromInvoices(List<PerformanceInvoice> invoices) {
    if (invoices.isEmpty) {
      return PerformanceStats(
        totalRevenue: 0,
        totalPaid: 0,
        totalPending: 0,
        totalTransactions: 0,
        totalSales: 0,
        totalReservations: 0,
        averageTransactionValue: 0,
        totalCommissions: 0,
        revenueByEstate: {},
        transactionsByType: {},
        revenueByMonth: {},
      );
    }

    final totalRevenue =
        invoices.fold<double>(0, (sum, inv) => sum + inv.amount);
    final totalPaid = invoices
        .where((inv) => inv.paymentStatus == 'Paid')
        .fold<double>(0, (sum, inv) => sum + (inv.amountPaid ?? inv.amount));
    final totalPending = invoices
        .where((inv) => inv.paymentStatus == 'Pending')
        .fold<double>(0, (sum, inv) => sum + inv.amount);

    final totalSales =
        invoices.where((inv) => inv.transactionType == 'Sale').length;
    final totalReservations =
        invoices.where((inv) => inv.transactionType == 'Reservation').length;

    final totalCommissions = invoices.fold<double>(
        0, (sum, inv) => sum + (inv.commissionAmount ?? 0));

    // Revenue by estate
    final Map<String, double> revenueByEstate = {};
    for (var invoice in invoices) {
      revenueByEstate[invoice.estateName] =
          (revenueByEstate[invoice.estateName] ?? 0) + invoice.amount;
    }

    // Transactions by type
    final Map<String, int> transactionsByType = {};
    for (var invoice in invoices) {
      transactionsByType[invoice.transactionType] =
          (transactionsByType[invoice.transactionType] ?? 0) + 1;
    }

    // Revenue by month
    final Map<String, double> revenueByMonth = {};
    for (var invoice in invoices) {
      final monthKey =
          '${invoice.transactionDate.year}-${invoice.transactionDate.month.toString().padLeft(2, '0')}';
      revenueByMonth[monthKey] =
          (revenueByMonth[monthKey] ?? 0) + invoice.amount;
    }

    return PerformanceStats(
      totalRevenue: totalRevenue,
      totalPaid: totalPaid,
      totalPending: totalPending,
      totalTransactions: invoices.length,
      totalSales: totalSales,
      totalReservations: totalReservations,
      averageTransactionValue:
          invoices.isEmpty ? 0 : totalRevenue / invoices.length,
      totalCommissions: totalCommissions,
      revenueByEstate: revenueByEstate,
      transactionsByType: transactionsByType,
      revenueByMonth: revenueByMonth,
    );
  }
}
