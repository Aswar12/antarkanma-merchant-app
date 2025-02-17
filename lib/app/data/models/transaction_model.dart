import 'package:antarkanma_merchant/app/data/models/order_item_model.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/data/models/user_model.dart';

class OrderModel {
  final dynamic id;
  final String orderStatus;
  final double totalAmount;
  final DateTime? createdAt;
  final List<OrderItemModel> orderItems;

  OrderModel({
    this.id,
    required this.orderStatus,
    required this.totalAmount,
    this.createdAt,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> orderItems = [];
    if (json['order_items'] != null) {
      orderItems = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    // Handle total_amount that could be string or number
    double amount = 0.0;
    if (json['total_amount'] != null) {
      if (json['total_amount'] is num) {
        amount = (json['total_amount'] as num).toDouble();
      } else if (json['total_amount'] is String) {
        amount = double.tryParse(json['total_amount']) ?? 0.0;
      }
    }

    return OrderModel(
      id: json['id'],
      orderStatus: json['order_status']?.toString() ?? 'PENDING',
      totalAmount: amount,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      orderItems: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_status': orderStatus,
      'total_amount': totalAmount,
      'created_at': createdAt?.toIso8601String(),
      'order_items': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class TransactionModel {
  final dynamic id;
  final dynamic orderId;
  final int userId;
  final int userLocationId;
  final double totalPrice;
  final double shippingPrice;
  final String paymentMethod;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;
  final String? note;
  final List<OrderItemModel> items;
  final UserLocationModel? userLocation;
  final OrderModel? order;
  final UserModel? user;

  TransactionModel({
    this.id,
    this.orderId,
    required this.userId,
    required this.userLocationId,
    required this.totalPrice,
    required this.shippingPrice,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    this.createdAt,
    this.note,
    required this.items,
    this.userLocation,
    this.order,
    this.user,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both old and new JSON structures
      final transactionData = json['data'] != null ? json['data'] : json;
      
      // Parse order items
      List<OrderItemModel> orderItems = [];
      if (transactionData['order'] != null && transactionData['order']['order_items'] != null) {
        orderItems = (transactionData['order']['order_items'] as List)
            .map((item) => OrderItemModel.fromJson(item))
            .toList();
      } else if (transactionData['items'] != null) {
        orderItems = _parseItems(transactionData['items']);
      }

      // Parse user location
      UserLocationModel? userLocation;
      if (transactionData['user_location'] != null) {
        userLocation = UserLocationModel.fromJson(transactionData['user_location']);
      }

      // Parse order with new structure
      OrderModel? order;
      if (transactionData['order'] != null) {
        order = OrderModel.fromJson(transactionData['order']);
      }

      // Parse user
      UserModel? user;
      if (transactionData['user'] != null) {
        user = UserModel.fromJson(transactionData['user']);
      }

      // Parse prices that could be string or number
      double totalPrice = 0.0;
      if (transactionData['total_price'] != null || transactionData['total_amount'] != null) {
        var priceValue = transactionData['total_price'] ?? transactionData['total_amount'];
        if (priceValue is num) {
          totalPrice = priceValue.toDouble();
        } else if (priceValue is String) {
          totalPrice = double.tryParse(priceValue) ?? 0.0;
        }
      }

      double shippingPrice = 0.0;
      if (transactionData['shipping_price'] != null) {
        var shipValue = transactionData['shipping_price'];
        if (shipValue is num) {
          shippingPrice = shipValue.toDouble();
        } else if (shipValue is String) {
          shippingPrice = double.tryParse(shipValue) ?? 0.0;
        }
      }

      return TransactionModel(
        id: transactionData['id'],
        orderId: transactionData['order_id'],
        userId: _parseId(transactionData['user_id']) ?? 0,
        userLocationId: _parseId(transactionData['user_location_id']) ?? 0,
        totalPrice: totalPrice,
        shippingPrice: shippingPrice,
        paymentMethod: transactionData['payment_method']?.toString() ?? 'MANUAL',
        status: transactionData['status']?.toString() ?? order?.orderStatus ?? 'PENDING',
        paymentStatus: transactionData['payment_status']?.toString() ?? 'PENDING',
        createdAt: transactionData['created_at'] != null
            ? DateTime.tryParse(transactionData['created_at'].toString())
            : null,
        note: transactionData['note']?.toString(),
        items: orderItems,
        userLocation: userLocation,
        order: order,
        user: user,
      );
    } catch (e, stackTrace) {
      print('Error parsing TransactionModel: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<OrderItemModel> _parseItems(dynamic items) {
    if (items == null) return [];
    if (items is! List) return [];

    return items.map((item) {
      try {
        return OrderItemModel.fromJson(item);
      } catch (e) {
        print('Error parsing order item: $e');
        print('Item data: $item');
        rethrow;
      }
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'user_location_id': userLocationId,
      'total_amount': totalPrice,
      'shipping_price': shippingPrice,
      'payment_method': paymentMethod,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
      'note': note,
      'items': items.map((item) => item.toJson()).toList(),
      'user_location': userLocation?.toJson(),
      'order': order?.toJson(),
      'user': user?.toJson(),
    };
  }

  // Getters for formatted values
  double get subtotal => totalPrice;
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';
  double get shippingCost => shippingPrice;
  String get formattedShippingCost => 'Rp ${shippingCost.toStringAsFixed(0)}';
  double get grandTotal => totalPrice + shippingPrice;
  String get formattedGrandTotal => 'Rp ${grandTotal.toStringAsFixed(0)}';
  String get formattedTotalPrice => 'Rp ${totalPrice.toStringAsFixed(0)}';
  String get formattedShippingPrice => 'Rp ${shippingPrice.toStringAsFixed(0)}';
  String get formattedDate => createdAt?.toString() ?? '-';

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu Konfirmasi';
      case 'ACCEPTED':
        return 'Diterima';
      case 'REJECTED':
        return 'Ditolak';
      case 'PROCESSING':
        return 'Sedang Diproses';
      case 'READYTOPICKUP':
        return 'Siap Antar';
      case 'SHIPPED':
        return 'Dalam Pengiriman';
      case 'DELIVERED':
        return 'Terkirim';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  TransactionModel copyWith({
    dynamic id,
    dynamic orderId,
    int? userId,
    int? userLocationId,
    double? totalPrice,
    double? shippingPrice,
    String? paymentMethod,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    String? note,
    List<OrderItemModel>? items,
    UserLocationModel? userLocation,
    OrderModel? order,
    UserModel? user,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userLocationId: userLocationId ?? this.userLocationId,
      totalPrice: totalPrice ?? this.totalPrice,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      items: items ?? this.items,
      userLocation: userLocation ?? this.userLocation,
      order: order ?? this.order,
      user: user ?? this.user,
    );
  }
}
