import 'package:flutter/material.dart';

// Invoice Status Enums
enum ServiceInvoiceStatus {
  draft,
  sent,
  viewed,
  overdue,
  cancelled,
  void_;

  String toDisplayString() {
    switch (this) {
      case ServiceInvoiceStatus.draft:
        return 'Draft';
      case ServiceInvoiceStatus.sent:
        return 'Sent';
      case ServiceInvoiceStatus.viewed:
        return 'Viewed';
      case ServiceInvoiceStatus.overdue:
        return 'Overdue';
      case ServiceInvoiceStatus.cancelled:
        return 'Cancelled';
      case ServiceInvoiceStatus.void_:
        return 'Void';
    }
  }

  Color getStatusColor() {
    switch (this) {
      case ServiceInvoiceStatus.draft:
        return Colors.blue;
      case ServiceInvoiceStatus.sent:
        return Colors.orange;
      case ServiceInvoiceStatus.viewed:
        return Colors.purple;
      case ServiceInvoiceStatus.overdue:
        return Colors.red;
      case ServiceInvoiceStatus.cancelled:
        return Colors.grey;
      case ServiceInvoiceStatus.void_:
        return Colors.grey;
    }
  }
}

enum ServicePaymentStatus {
  unpaid,
  partiallyPaid,
  paid,
  refunded,
  cancelled;

  String toDisplayString() {
    switch (this) {
      case ServicePaymentStatus.unpaid:
        return 'Unpaid';
      case ServicePaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case ServicePaymentStatus.paid:
        return 'Paid';
      case ServicePaymentStatus.refunded:
        return 'Refunded';
      case ServicePaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color getStatusColor() {
    switch (this) {
      case ServicePaymentStatus.unpaid:
        return Colors.red;
      case ServicePaymentStatus.partiallyPaid:
        return Colors.orange;
      case ServicePaymentStatus.paid:
        return Colors.green;
      case ServicePaymentStatus.refunded:
        return Colors.blue;
      case ServicePaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}

// Invoice Item
class ServiceInvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final String? unit; // 'sqm', 'plot', 'hour', etc.

  ServiceInvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.unit,
  });

  double get amount => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unit': unit,
    };
  }

  factory ServiceInvoiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceInvoiceItem(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: map['unitPrice'] ?? 0.0,
      unit: map['unit'],
    );
  }
}

// Service Invoice Model
class ServiceInvoice {
  final String id;
  final String invoiceNumber;

  // Lead/Client Information
  final String leadId;
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? clientAddress;

  // Service Information
  final String
      serviceType; // 'Real Estate', 'Land Survey', 'Property Management', etc.
  final String? propertyAddress;
  final String? propertyDetails;

  // Financial Details
  final List<ServiceInvoiceItem> items;
  final double subtotal;
  final double taxRate; // Default: 7.5%
  final double taxAmount;
  final double discount;
  final double totalAmount;
  final String currency; // Default: '₦'

  // Dates
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;

  // Status
  final ServiceInvoiceStatus status;
  final ServicePaymentStatus paymentStatus;

  // Payment Tracking
  final double amountPaid;
  final double balance;
  final List<ServicePayment> payments;

  // Additional Information
  final String? notes;
  final String? termsAndConditions;
  final List<String> attachments;

  // Audit Trail
  final String createdBy;
  final DateTime createdDate;
  final String? lastModifiedBy;
  final DateTime? lastModifiedDate;

  ServiceInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.leadId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    required this.serviceType,
    this.propertyAddress,
    this.propertyDetails,
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
    this.status = ServiceInvoiceStatus.draft,
    this.paymentStatus = ServicePaymentStatus.unpaid,
    this.amountPaid = 0,
    this.balance = 0,
    this.payments = const [],
    this.notes,
    this.termsAndConditions,
    this.attachments = const [],
    required this.createdBy,
    required this.createdDate,
    this.lastModifiedBy,
    this.lastModifiedDate,
  });

  // Calculate total from items
  static double calculateSubtotal(List<ServiceInvoiceItem> items) {
    return items.fold(0, (sum, item) => sum + item.amount);
  }

  // Calculate tax
  static double calculateTax(double subtotal, double taxRate) {
    return subtotal * (taxRate / 100);
  }

  // Calculate total
  static double calculateTotal(double subtotal, double tax, double discount) {
    return subtotal + tax - discount;
  }

  // Generate invoice number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final milliseconds =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return 'SRV-${now.year}-${now.month.toString().padLeft(2, '0')}-$milliseconds';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'leadId': leadId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
      'serviceType': serviceType,
      'propertyAddress': propertyAddress,
      'propertyDetails': propertyDetails,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discount': discount,
      'totalAmount': totalAmount,
      'currency': currency,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.toString(),
      'paymentStatus': paymentStatus.toString(),
      'amountPaid': amountPaid,
      'balance': balance,
      'payments': payments.map((p) => p.toMap()).toList(),
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'attachments': attachments,
      'createdBy': createdBy,
      'createdDate': createdDate.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
    };
  }

  factory ServiceInvoice.fromMap(Map<String, dynamic> map) {
    return ServiceInvoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      leadId: map['leadId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientEmail: map['clientEmail'],
      clientPhone: map['clientPhone'],
      clientAddress: map['clientAddress'],
      serviceType: map['serviceType'] ?? '',
      propertyAddress: map['propertyAddress'],
      propertyDetails: map['propertyDetails'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ServiceInvoiceItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      taxRate: (map['taxRate'] ?? 7.5).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      currency: map['currency'] ?? '₦',
      issueDate:
          DateTime.parse(map['issueDate'] ?? DateTime.now().toIso8601String()),
      dueDate:
          DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      paidDate:
          map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
      createdBy: map['createdBy'] ?? '',
      createdDate: DateTime.parse(
          map['createdDate'] ?? DateTime.now().toIso8601String()),
      lastModifiedBy: map['lastModifiedBy'],
      lastModifiedDate: map['lastModifiedDate'] != null
          ? DateTime.parse(map['lastModifiedDate'])
          : null,
    );
  }
}

// Service Payment Model
class ServicePayment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final String
      paymentMethod; // 'Cash', 'Bank Transfer', 'Card', 'Cheque', 'Mobile Wallet'
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String? transactionReference;
  final String? bankingDetails;
  final String? notes;

  ServicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.status = 'Pending',
    this.transactionReference,
    this.bankingDetails,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionReference': transactionReference,
      'bankingDetails': bankingDetails,
      'notes': notes,
    };
  }

  factory ServicePayment.fromMap(Map<String, dynamic> map) {
    return ServicePayment(
      id: map['id'] ?? '',
      invoiceId: map['invoiceId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(
          map['paymentDate'] ?? DateTime.now().toIso8601String()),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'Pending',
      transactionReference: map['transactionReference'],
      bankingDetails: map['bankingDetails'],
      notes: map['notes'],
    );
  }
}
