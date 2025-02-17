enum OrderItemStatus {
  pending,
  waitingApproval,
  processing,
  ready,
  pickedUp,
  completed,
  canceled;

  String get value {
    switch (this) {
      case OrderItemStatus.pending:
        return 'PENDING';
      case OrderItemStatus.waitingApproval:
        return 'WAITING_APPROVAL';
      case OrderItemStatus.processing:
        return 'PROCESSING';
      case OrderItemStatus.ready:
        return 'READY';
      case OrderItemStatus.pickedUp:
        return 'PICKED_UP';
      case OrderItemStatus.completed:
        return 'COMPLETED';
      case OrderItemStatus.canceled:
        return 'CANCELED';
    }
  }

  static OrderItemStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return OrderItemStatus.pending;
      case 'WAITING_APPROVAL':
        return OrderItemStatus.waitingApproval;
      case 'PROCESSING':
        return OrderItemStatus.processing;
      case 'READY':
        return OrderItemStatus.ready;
      case 'PICKED_UP':
        return OrderItemStatus.pickedUp;
      case 'COMPLETED':
        return OrderItemStatus.completed;
      case 'CANCELED':
        return OrderItemStatus.canceled;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}
