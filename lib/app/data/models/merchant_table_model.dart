class MerchantTableModel {
  final int? id;
  final int? merchantId;
  final String tableNumber;
  final int capacity;
  final String status;
  final int? currentPosTransactionId;
  final Map<String, dynamic>? currentTransaction;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MerchantTableModel({
    this.id,
    this.merchantId,
    required this.tableNumber,
    this.capacity = 4,
    this.status = 'AVAILABLE',
    this.currentPosTransactionId,
    this.currentTransaction,
    this.createdAt,
    this.updatedAt,
  });

  // Status constants
  static const String statusAvailable = 'AVAILABLE';
  static const String statusOccupied = 'OCCUPIED';
  static const String statusReserved = 'RESERVED';

  bool get isAvailable => status == statusAvailable;
  bool get isOccupied => status == statusOccupied;
  bool get isReserved => status == statusReserved;

  String get statusDisplay {
    switch (status) {
      case statusAvailable:
        return 'Tersedia';
      case statusOccupied:
        return 'Terisi';
      case statusReserved:
        return 'Dipesan';
      default:
        return status;
    }
  }

  factory MerchantTableModel.fromJson(Map<String, dynamic> json) {
    return MerchantTableModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      tableNumber: json['table_number'] ?? '',
      capacity: json['capacity'] ?? 4,
      status: json['status'] ?? 'AVAILABLE',
      currentPosTransactionId: json['current_pos_transaction_id'],
      currentTransaction: json['current_transaction'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
    };
  }

  MerchantTableModel copyWith({
    int? id,
    int? merchantId,
    String? tableNumber,
    int? capacity,
    String? status,
    int? currentPosTransactionId,
    Map<String, dynamic>? currentTransaction,
  }) {
    return MerchantTableModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentPosTransactionId:
          currentPosTransactionId ?? this.currentPosTransactionId,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
