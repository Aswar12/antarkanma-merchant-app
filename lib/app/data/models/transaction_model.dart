import 'package:antarkanma_merchant/app/data/models/order_item_model.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/data/models/user_model.dart';
import 'package:antarkanma_merchant/app/data/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class OrderModel {
  final dynamic id;
  final String orderStatus;
  final double totalAmount;
  final List<OrderItemModel> orderItems;

  OrderModel({
    this.id,
    required this.orderStatus,
    required this.totalAmount,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderStatus: json['order_status'] ?? 'PENDING',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      orderItems: (json['order_items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_status': orderStatus,
      'total_amount': totalAmount,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class TransactionModel {
  final dynamic id;
  final dynamic transactionId;
  final double totalAmount;
  final String orderStatus;
  final String merchantApproval;
  final DateTime? createdAt;
  final List<OrderItemModel> orderItems;
  final Map<String, dynamic>? transaction;
  final List<ItemModel> items;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? courier;
  final double total;
  final double shippingPrice;
  final UserModel? user;
  final String status;
  final OrderModel? order;

  TransactionModel({
    this.id,
    this.transactionId,
    required this.totalAmount,
    required this.orderStatus,
    required this.merchantApproval,
    this.createdAt,
    required this.orderItems,
    this.transaction,
    required this.items,
    this.customer,
    this.courier,
    required this.total,
    this.shippingPrice = 0.0,
    this.user,
    this.status = 'PENDING',
    this.order,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      orderStatus: json['order_status'] ?? 'PENDING',
      merchantApproval: json['merchant_approval'] ?? 'PENDING',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      orderItems: (json['order_items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      transaction: json['transaction'] as Map<String, dynamic>?,
      items: (json['items'] as List?)
              ?.map((item) => ItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      customer: json['customer'] as Map<String, dynamic>?,
      courier: json['courier'] as Map<String, dynamic>?,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      shippingPrice: double.tryParse(json['shipping_price']?.toString() ?? '0') ?? 0.0,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      status: json['status'] ?? 'PENDING',
      order: json['order'] != null ? OrderModel.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'total_amount': totalAmount,
      'order_status': orderStatus,
      'merchant_approval': merchantApproval,
      'created_at': createdAt?.toIso8601String(),
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'transaction': transaction,
      'items': items.map((item) => item.toJson()).toList(),
      'customer': customer,
      'courier': courier,
      'total': total,
      'shipping_price': shippingPrice,
      'user': user?.toJson(),
      'status': status,
      'order': order?.toJson(),
    };
  }

  // Getters for formatted values
  String get formattedTotalAmount {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalAmount);
  }

  String get formattedTotalPrice => formattedTotalAmount;

  String get formattedShippingPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(shippingPrice);
  }

  double get grandTotal => totalAmount + shippingPrice;

  String get formattedGrandTotal {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(grandTotal);
  }

  // Order-related getters
  dynamic get orderId => id;

  String get statusDisplay {
    switch (orderStatus.toUpperCase()) {
      case 'WAITING_APPROVAL':
        return 'Menunggu Persetujuan';
      case 'PENDING':
        return 'Menunggu Konfirmasi';
      case 'PROCESSING':
        return 'Sedang Diproses';
      case 'READY':
        return 'Siap Diambil';
      case 'PICKED_UP':
        return 'Dalam Pengiriman';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELED':
        return 'Dibatalkan';
      default:
        return orderStatus;
    }
  }

  Color getStatusColor() {
    switch (orderStatus.toUpperCase()) {
      case 'WAITING_APPROVAL':
        return Colors.orange;
      case 'PENDING':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.green;
      case 'READY':
        return Colors.teal;
      case 'PICKED_UP':
        return Colors.indigo;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get canBeApproved {
    return orderStatus.toUpperCase() == 'WAITING_APPROVAL' &&
        merchantApproval.toUpperCase() == 'PENDING';
  }

  bool get canBeRejected {
    return orderStatus.toUpperCase() == 'WAITING_APPROVAL' &&
        merchantApproval.toUpperCase() == 'PENDING';
  }

  // Customer-related getters
  String get customerName => customer?['name'] ?? user?.name ?? 'Customer';
  String get customerPhone => customer?['phone'] ?? user?.phoneNumber ?? '-';

  TransactionModel copyWith({
    dynamic id,
    dynamic transactionId,
    double? totalAmount,
    String? orderStatus,
    String? merchantApproval,
    DateTime? createdAt,
    List<OrderItemModel>? orderItems,
    Map<String, dynamic>? transaction,
    List<ItemModel>? items,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? courier,
    double? total,
    double? shippingPrice,
    UserModel? user,
    String? status,
    OrderModel? order,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      merchantApproval: merchantApproval ?? this.merchantApproval,
      createdAt: createdAt ?? this.createdAt,
      orderItems: orderItems ?? this.orderItems,
      transaction: transaction ?? this.transaction,
      items: items ?? this.items,
      customer: customer ?? this.customer,
      courier: courier ?? this.courier,
      total: total ?? this.total,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      user: user ?? this.user,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }
}
