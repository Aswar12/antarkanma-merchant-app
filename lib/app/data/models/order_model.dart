import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderModel {
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_WAITING_APPROVAL = 'WAITING_APPROVAL';
  static const String STATUS_PROCESSING = 'PROCESSING';
  static const String STATUS_READY_FOR_PICKUP = 'READY_FOR_PICKUP';
  static const String STATUS_COMPLETED = 'COMPLETED';
  static const String STATUS_CANCELED = 'CANCELED';
  static const String STATUS_PICKED_UP = 'PICKED_UP';

  final int id;
  final int transactionId;
  final double totalAmount;
  final String orderStatus;
  final String merchantApproval;
  final String? rejectionReason;
  final DateTime createdAt;
  final List<OrderItem> orderItems;
  final List<OrderItem> items;
  final TransactionInfo transaction;
  final CustomerInfo customer;
  final CourierInfo? courier;
  final String? notes;
  final double subtotal;
  final double shippingCost;
  final double? discount;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.transactionId,
    required this.totalAmount,
    required this.orderStatus,
    required this.merchantApproval,
    this.rejectionReason,
    required this.createdAt,
    required this.orderItems,
    required this.transaction,
    required this.customer,
    this.courier,
    this.notes,
    required this.subtotal,
    required this.shippingCost,
    this.discount,
    required this.paymentMethod,
  }) : items = orderItems;

  // Helper method to check if order needs approval
  bool get isWaitingApproval => 
      orderStatus == STATUS_PENDING || orderStatus == STATUS_WAITING_APPROVAL;

  // Helper method to check if order is being processed
  bool get isProcessing => orderStatus == STATUS_PROCESSING;

  // Helper method to check if order is ready for pickup
  bool get isReadyForPickup => orderStatus == STATUS_READY_FOR_PICKUP;

  // Helper method to check if order is completed
  bool get isCompleted => orderStatus == STATUS_COMPLETED;

  // Helper method to check if order is canceled
  bool get isCanceled => orderStatus == STATUS_CANCELED;

  String get formattedTotalAmount => _formatCurrency(totalAmount);
  String get formattedTotal => _formatCurrency(totalAmount);
  String get formattedSubtotal => _formatCurrency(subtotal);
  String get formattedShippingCost => _formatCurrency(shippingCost);
  String get formattedDiscount => _formatCurrency(discount ?? 0);
  String get orderNumber => id.toString();
  double get total => totalAmount;
  String get status => orderStatus;
  String get shippingAddress => customer.deliveryAddress?.fullAddress ?? '';

  String get statusDisplay {
    switch (orderStatus) {
      case STATUS_WAITING_APPROVAL:
        return 'Menunggu';
      case STATUS_PROCESSING:
        return 'Diproses';
      case STATUS_READY_FOR_PICKUP:
        return 'Siap Diambil';
      case STATUS_COMPLETED:
        return 'Selesai';
      case STATUS_CANCELED:
        return 'Dibatalkan';
      default:
        return orderStatus;
    }
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  String get customerName => customer.name ?? 'Unknown Customer';
  String get customerPhone => customer.phone ?? '-';

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      final orderItems = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();

      final customerData = json['customer'] as Map<String, dynamic>;
      final deliveryAddressData =
          customerData['delivery_address'] as Map<String, dynamic>?;
      final transactionData = json['transaction'] as Map<String, dynamic>;

      // Parse amounts with proper null checks
      final totalAmount = double.parse(json['total_amount'].toString());
      final subtotal = json['subtotal'] != null
          ? double.parse(json['subtotal'].toString())
          : totalAmount;
      final shippingCost = transactionData['shipping_price'] != null
          ? double.parse(transactionData['shipping_price'].toString())
          : 0.0;
      final discount = json['discount'] != null
          ? double.parse(json['discount'].toString())
          : null;

      return OrderModel(
        id: json['id'] as int,
        transactionId: json['transaction_id'] as int,
        totalAmount: totalAmount,
        orderStatus: json['order_status'] as String,
        merchantApproval: json['merchant_approval'] as String,
        rejectionReason: json['rejection_reason'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        orderItems: orderItems,
        transaction: TransactionInfo.fromJson(transactionData),
        customer: CustomerInfo(
          name: customerData['name'] as String?,
          phone: customerData['phone'] as String?,
          photo: customerData['photo'] as String?,
          deliveryAddress: deliveryAddressData != null
              ? DeliveryAddress.fromJson(deliveryAddressData)
              : null,
        ),
        courier: json['courier'] != null
            ? CourierInfo.fromJson(json['courier'] as Map<String, dynamic>)
            : null,
        notes: json['notes'] as String?,
        subtotal: subtotal,
        shippingCost: shippingCost,
        discount: discount,
        paymentMethod: transactionData['payment_method'] as String,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing OrderModel: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int? productVariantId;
  final int quantity;
  final double price;
  final String? customerNote;
  final ProductInfo product;
  final ProductVariant? variant;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productVariantId,
    required this.quantity,
    required this.price,
    this.customerNote,
    required this.product,
    this.variant,
  });

  String get formattedPrice => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(price);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productVariantId: json['product_variant_id'] as int?,
      quantity: json['quantity'] as int,
      price: double.parse(json['price'].toString()),
      customerNote: json['customer_note'] as String?,
      product: ProductInfo.fromJson(json['product'] as Map<String, dynamic>),
      variant:
          json['variant'] != null && json['variant'] is Map<String, dynamic>
              ? ProductVariant.fromJson(json['variant'] as Map<String, dynamic>)
              : null,
    );
  }
}

class ProductInfo {
  final int id;
  final String name;
  final double price;
  final String status;
  final List<GalleryInfo> galleries;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
    required this.galleries,
  });

  String? get firstImageUrl =>
      galleries.isNotEmpty ? galleries.first.url : null;

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      status: json['status'] as String,
      galleries: (json['galleries'] as List)
          .map((gallery) =>
              GalleryInfo.fromJson(gallery as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductVariant {
  final int? id;
  final String? name;
  final double? price;

  ProductVariant({
    this.id,
    this.name,
    this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int?,
      name: json['name'] as String?,
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
    );
  }
}

class GalleryInfo {
  final int id;
  final int productId;
  final String url;

  GalleryInfo({
    required this.id,
    required this.productId,
    required this.url,
  });

  factory GalleryInfo.fromJson(Map<String, dynamic> json) {
    return GalleryInfo(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      url: json['url'] as String,
    );
  }
}

class TransactionInfo {
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double shippingPrice;

  TransactionInfo({
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingPrice,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      shippingPrice: json['shipping_price'] != null
          ? double.parse(json['shipping_price'].toString())
          : 0.0,
    );
  }
}

class CustomerInfo {
  final String? name;
  final String? phone;
  final String? photo;
  final DeliveryAddress? deliveryAddress;

  String? get phoneNumber => phone;

  CustomerInfo({
    this.name,
    this.phone,
    this.photo,
    this.deliveryAddress,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    try {
      return CustomerInfo(
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        photo: json['photo'] as String?,
        deliveryAddress: json['delivery_address'] != null
            ? DeliveryAddress.fromJson(
                json['delivery_address'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing CustomerInfo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class DeliveryAddress {
  final String customerName;
  final String address;
  final String city;
  final String district;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? notes;

  DeliveryAddress({
    required this.customerName,
    required this.address,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.notes,
  });

  String get fullAddress => '$address, $district, $city $postalCode';

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    try {
      return DeliveryAddress(
        customerName: json['customer_name'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        district: json['district'] as String,
        postalCode: json['postal_code'] as String,
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
        phoneNumber: json['phone_number'] as String,
        notes: json['notes'] as String?,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing DeliveryAddress: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

class CourierInfo {
  final String? name;
  final String? phone;
  final String? vehicle;
  final String? plate;
  final String? photo;

  CourierInfo({
    this.name,
    this.phone,
    this.vehicle,
    this.plate,
    this.photo,
  });

  factory CourierInfo.fromJson(Map<String, dynamic> json) {
    // Handle null values gracefully
    return CourierInfo(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      vehicle: json['vehicle'] as String?,
      plate: json['plate'] as String?,
      photo: json['photo'] as String?,
    );
  }
}
