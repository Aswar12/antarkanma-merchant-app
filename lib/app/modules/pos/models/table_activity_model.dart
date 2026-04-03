import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';

class TableActivityModel {
  final int id;
  final int merchantId;
  final int? merchantTableId;
  final int? posTransactionId;
  final int? userId;
  final String activityType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final MerchantTableModel? table;
  final PosTransactionModel? transaction;
  final String? userName;

  TableActivityModel({
    required this.id,
    required this.merchantId,
    this.merchantTableId,
    this.posTransactionId,
    this.userId,
    required this.activityType,
    this.metadata,
    required this.createdAt,
    this.table,
    this.transaction,
    this.userName,
  });

  static const String typeOccupied = 'OCCUPIED';
  static const String typeFoodCompleted = 'FOOD_COMPLETED';
  static const String typeExtended = 'EXTENDED';
  static const String typeReleased = 'RELEASED';
  static const String typeAutoReleased = 'AUTO_RELEASED';

  String get activityTypeDisplay {
    switch (activityType) {
      case typeOccupied:
        return 'Meja Terisi';
      case typeFoodCompleted:
        return 'Makanan Disajikan';
      case typeExtended:
        return 'Durasi Ditambah';
      case typeReleased:
        return 'Meja Dilepas';
      case typeAutoReleased:
        return 'Auto-Release';
      default:
        return activityType;
    }
  }

  factory TableActivityModel.fromJson(Map<String, dynamic> json) {
    return TableActivityModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      merchantTableId: json['merchant_table_id'],
      posTransactionId: json['pos_transaction_id'],
      userId: json['user_id'],
      activityType: json['activity_type'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      table: json['table'] != null
          ? MerchantTableModel.fromJson(json['table'])
          : null,
      transaction: json['transaction'] != null
          ? PosTransactionModel.fromJson(json['transaction'])
          : null,
      userName: json['user']?['name'],
    );
  }
}

class TableReadyToRelease {
  final int transactionId;
  final String transactionCode;
  final String tableNumber;
  final DateTime autoReleaseAt;
  final int minutesRemaining;
  final bool isOverdue;
  final DateTime? foodCompletedAt;

  TableReadyToRelease({
    required this.transactionId,
    required this.transactionCode,
    required this.tableNumber,
    required this.autoReleaseAt,
    required this.minutesRemaining,
    required this.isOverdue,
    this.foodCompletedAt,
  });

  factory TableReadyToRelease.fromJson(Map<String, dynamic> json) {
    return TableReadyToRelease(
      transactionId: json['transaction_id'],
      transactionCode: json['transaction_code'],
      tableNumber: json['table_number'],
      autoReleaseAt: DateTime.parse(json['auto_release_at']),
      minutesRemaining: json['minutes_remaining'],
      isOverdue: json['is_overdue'] ?? false,
      foodCompletedAt: json['food_completed_at'] != null
          ? DateTime.parse(json['food_completed_at'])
          : null,
    );
  }
}
