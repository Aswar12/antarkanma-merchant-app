import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';

class DeliveryModel {
  final int id;
  final String status;
  final DateTime? actualDeliveryTime;
  final String? failureReason;
  final DateTime? rescheduleDate;
  final bool? paymentCollected;
  final double? amountCollected;
  final String? notes;
  final TransactionModel transaction;

  DeliveryModel({
    required this.id,
    required this.status,
    this.actualDeliveryTime,
    this.failureReason,
    this.rescheduleDate,
    this.paymentCollected,
    this.amountCollected,
    this.notes,
    required this.transaction,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      status: json['status'],
      actualDeliveryTime: json['actual_delivery_time'] != null 
          ? DateTime.parse(json['actual_delivery_time'])
          : null,
      failureReason: json['failure_reason'],
      rescheduleDate: json['reschedule_date'] != null 
          ? DateTime.parse(json['reschedule_date'])
          : null,
      paymentCollected: json['payment_collected'],
      amountCollected: json['amount_collected'] != null 
          ? double.parse(json['amount_collected'])
          : null,
      notes: json['notes'],
      transaction: TransactionModel.fromJson(json['transaction']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'failure_reason': failureReason,
      'reschedule_date': rescheduleDate?.toIso8601String(),
      'payment_collected': paymentCollected,
      'amount_collected': amountCollected?.toString(),
      'notes': notes,
      'transaction': transaction.toJson(),
    };
  }
}
