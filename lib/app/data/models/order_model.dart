import 'package:intl/intl.dart';

class OrderModel {
  final int id;
  final int transactionId;
  final String totalAmount;
  final String orderStatus;
  final String merchantApproval;
  final String createdAt;
  final List<OrderItem> items;
  final TransactionInfo transaction;
  final CustomerInfo customer;
  final CourierInfo? courier;

  OrderModel({
    required this.id,
    required this.transactionId,
    required this.totalAmount,
    required this.orderStatus,
    required this.merchantApproval,
    required this.createdAt,
    required this.items,
    required this.transaction,
    required this.customer,
    this.courier,
  });

  String get customerName => customer.name;
  String get customerPhone => customer.phone;
  String get statusDisplay {
    switch (orderStatus) {
      case 'WAITING_APPROVAL':
        return 'Menunggu Persetujuan';
      case 'PROCESSING':
        return 'Diproses';
      case 'READY_FOR_PICKUP':
        return 'Siap Diambil';
      case 'PICKED_UP':
        return 'Dalam Pengantaran';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELED':
        return 'Dibatalkan';
      default:
        return 'Pending';
    }
  }

  String get formattedTotalAmount {
    final amount = double.tryParse(totalAmount) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      totalAmount: json['total_amount'],
      orderStatus: json['order_status'],
      merchantApproval: json['merchant_approval'],
      createdAt: json['created_at'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      transaction: TransactionInfo.fromJson(json['transaction']),
      customer: CustomerInfo.fromJson(json['customer']),
      courier: json['courier'] != null ? CourierInfo.fromJson(json['courier']) : null,
    );
  }
}

class OrderItem {
  final int quantity;
  final String price;
  final ProductInfo product;

  OrderItem({
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      quantity: json['quantity'],
      price: json['price'],
      product: ProductInfo.fromJson(json['product']),
    );
  }
}

class ProductInfo {
  final String name;
  final String price;
  final String? firstImageUrl;

  ProductInfo({
    required this.name,
    required this.price,
    this.firstImageUrl,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['name'],
      price: json['price'],
      firstImageUrl: json['image'] ?? json['galleries']?[0]?['url'],
    );
  }
}

class TransactionInfo {
  final String status;
  final String paymentMethod;
  final String paymentStatus;

  TransactionInfo({
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
    );
  }
}

class CustomerInfo {
  final String name;
  final String phone;
  final String? photo;

  CustomerInfo({
    required this.name,
    required this.phone,
    this.photo,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      phone: json['phone'],
      photo: json['photo'],
    );
  }
}

class CourierInfo {
  final String name;
  final String phone;
  final String vehicle;
  final String plate;
  final String? photo;

  CourierInfo({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.plate,
    this.photo,
  });

  factory CourierInfo.fromJson(Map<String, dynamic> json) {
    return CourierInfo(
      name: json['name'],
      phone: json['phone'],
      vehicle: json['vehicle'],
      plate: json['plate'],
      photo: json['photo'],
    );
  }
}
