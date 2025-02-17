import 'package:intl/intl.dart';

bool canOrderBeCancelled(String status) {
  final upperStatus = status.toUpperCase();
  return upperStatus == 'PENDING' || upperStatus == 'PROCESSING';
}

String formatPrice(double price) {
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(price);
}
