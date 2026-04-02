class InvoiceItemOut {
  final int id;
  final String description;
  final int quantity;
  final String unitPrice;
  final String total;
  final String createdAt;
  final String updatedAt;

  InvoiceItemOut({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceItemOut.fromJson(Map<String, dynamic> json) {
    return InvoiceItemOut(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class ServiceOut {
  final int id;
  final String name;

  ServiceOut({required this.id, required this.name});

  factory ServiceOut.fromJson(Map<String, dynamic> json) {
    return ServiceOut(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ServiceOrderOut {
  final int id;
  final String orderNumber;

  ServiceOrderOut({required this.id, required this.orderNumber});

  factory ServiceOrderOut.fromJson(Map<String, dynamic> json) {
    return ServiceOrderOut(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
    );
  }
}

class ServiceLeadOut {
  final int id;
  final String name;

  ServiceLeadOut({required this.id, required this.name});

  factory ServiceLeadOut.fromJson(Map<String, dynamic> json) {
    return ServiceLeadOut(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ServiceInvoice {
  final int id;
  final String invoiceNumber;
  final int clientId;
  final ServiceOut service;
  final ServiceOrderOut? order;
  final ServiceLeadOut? lead;
  final String issueDate;
  final String dueDate;
  final String subtotal;
  final String taxRate;
  final String taxAmount;
  final String totalAmount;
  final String amountPaid;
  final String balance;
  final double paymentProgress;
  final String status;
  final String notes;
  final List<InvoiceItemOut> items;
  final String createdAt;
  final String updatedAt;
  final int createdById;

  ServiceInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.service,
    this.order,
    this.lead,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.balance,
    required this.paymentProgress,
    required this.status,
    required this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
  });

  factory ServiceInvoice.fromJson(Map<String, dynamic> json) {
    return ServiceInvoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      clientId: json['client_id'] ?? 0,
      service: json['service'] != null
          ? ServiceOut.fromJson(json['service'])
          : ServiceOut(id: 0, name: ''),
      order: json['order'] != null
          ? ServiceOrderOut.fromJson(json['order'])
          : null,
      lead: json['lead'] != null ? ServiceLeadOut.fromJson(json['lead']) : null,
      issueDate: json['issue_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      subtotal: json['subtotal']?.toString() ?? '0.00',
      taxRate: json['tax_rate']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      balance: json['balance']?.toString() ?? '0.00',
      paymentProgress: (json['payment_progress'] is num)
          ? (json['payment_progress'] as num).toDouble()
          : double.tryParse(json['payment_progress']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => InvoiceItemOut.fromJson(item))
              .toList()
          : [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdById: json['created_by_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'service_id': service.id,
      'order_id': order?.id,
      'lead_id': lead?.id,
      'issue_date': issueDate,
      'due_date': dueDate,
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'status': status,
      'notes': notes,
      'created_by_id': createdById,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
