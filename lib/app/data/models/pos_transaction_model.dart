import 'package:intl/intl.dart';

class PosTransactionItemModel {
  final int? id;
  final int? posTransactionId;
  final int? productId;
  final int? productVariantId;
  final String name;
  final int quantity;
  final double price;
  final double discount;
  final double subtotal;
  final String? notes;

  PosTransactionItemModel({
    this.id,
    this.posTransactionId,
    this.productId,
    this.productVariantId,
    required this.name,
    required this.quantity,
    required this.price,
    this.discount = 0,
    double? subtotal,
    this.notes,
  }) : subtotal = subtotal ?? ((price * quantity) - discount);

  factory PosTransactionItemModel.fromJson(Map<String, dynamic> json) {
    return PosTransactionItemModel(
      id: json['id'],
      posTransactionId: json['pos_transaction_id'],
      productId: json['product_id'],
      productVariantId: json['product_variant_id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'subtotal': subtotal,
      if (notes != null) 'notes': notes,
    };
  }

  String get formattedPrice => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(price);

  String get formattedSubtotal => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(subtotal);

  PosTransactionItemModel copyWith({
    int? id,
    int? productId,
    int? productVariantId,
    String? name,
    int? quantity,
    double? price,
    double? discount,
    String? notes,
  }) {
    final newQty = quantity ?? this.quantity;
    final newPrice = price ?? this.price;
    final newDiscount = discount ?? this.discount;
    return PosTransactionItemModel(
      id: id ?? this.id,
      posTransactionId: posTransactionId,
      productId: productId ?? this.productId,
      productVariantId: productVariantId ?? this.productVariantId,
      name: name ?? this.name,
      quantity: newQty,
      price: newPrice,
      discount: newDiscount,
      subtotal: (newPrice * newQty) - newDiscount,
      notes: notes ?? this.notes,
    );
  }
}

class PosTransactionModel {
  final int? id;
  final int? merchantId;
  final String? transactionCode;
  final String orderType; // DINE_IN, TAKEAWAY, DELIVERY
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String paymentMethod; // CASH, QRIS, TRANSFER
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final double changeAmount;
  final String? notes;
  final String status; // PENDING, PROCESSING, COMPLETED, VOIDED
  final String? tableNumber;
  final DateTime? createdAt;
  final List<PosTransactionItemModel> items;

  PosTransactionModel({
    this.id,
    this.merchantId,
    this.transactionCode,
    required this.orderType,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.amountPaid = 0,
    this.changeAmount = 0,
    this.notes,
    this.status = 'COMPLETED',
    this.tableNumber,
    this.createdAt,
    this.items = const [],
  });

  factory PosTransactionModel.fromJson(Map<String, dynamic> json) {
    return PosTransactionModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      transactionCode: json['transaction_code'],
      orderType: json['order_type'] ?? 'DINE_IN',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      deliveryAddress: json['delivery_address'],
      paymentMethod: json['payment_method'] ?? 'CASH',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      amountPaid: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0,
      changeAmount:
          double.tryParse(json['change_amount']?.toString() ?? '0') ?? 0,
      notes: json['notes'],
      status: json['status'] ?? 'COMPLETED',
      tableNumber: json['table_number'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      items: (json['items'] as List?)
              ?.map((item) => PosTransactionItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_type': orderType,
      'payment_method': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (tableNumber != null) 'table_number': tableNumber,
      'discount': discount,
      'tax': tax,
      if (amountPaid > 0) 'amount_paid': amountPaid,
      if (notes != null) 'notes': notes,
    };
  }

  // ─── Display Helpers ─────────────────────────────────────

  String get orderTypeDisplay {
    switch (orderType) {
      case 'DINE_IN':
        return 'Makan di Tempat';
      case 'TAKEAWAY':
        return 'Bawa Pulang';
      case 'DELIVERY':
        return 'Delivery';
      default:
        return orderType;
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'CASH':
        return 'Tunai';
      case 'QRIS':
        return 'QRIS';
      case 'TRANSFER':
        return 'Transfer';
      default:
        return paymentMethod;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'COMPLETED':
        return 'Selesai';
      case 'VOIDED':
        return 'Dibatalkan';
      case 'PENDING':
        return 'Menunggu';
      case 'PROCESSING':
        return 'Diproses';
      default:
        return status;
    }
  }

  String get formattedTotal => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(total);

  String get formattedSubtotal => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(subtotal);

  String get formattedAmountPaid => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amountPaid);

  String get formattedChangeAmount => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(changeAmount);

  String get formattedDate {
    if (createdAt == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt!);
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
