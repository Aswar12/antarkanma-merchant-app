import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:antarkanma_merchant/app/data/models/order_item_model.dart';
import 'package:antarkanma_merchant/app/data/models/user_model.dart';

class MerchantOrder {
  final int id;
  final int transactionId;
  final int merchantId;
  final int userId;
  final String orderStatus;
  final String merchantApproval;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel> items;
  final TransactionModel transaction;
  final UserModel user;

  MerchantOrder({
    required this.id,
    required this.transactionId,
    required this.merchantId,
    required this.userId,
    required this.orderStatus,
    required this.merchantApproval,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.transaction,
    required this.user,
  });

  factory MerchantOrder.fromJson(Map<String, dynamic> json) {
    return MerchantOrder(
      id: json['id'],
      transactionId: json['transaction_id'],
      merchantId: json['merchant_id'],
      userId: json['user_id'],
      orderStatus: json['order_status'],
      merchantApproval: json['merchant_approval'],
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      transaction: TransactionModel.fromJson(json['transaction']),
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'merchant_id': merchantId,
      'user_id': userId,
      'order_status': orderStatus,
      'merchant_approval': merchantApproval,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'transaction': transaction.toJson(),
      'user': user.toJson(),
    };
  }
}
