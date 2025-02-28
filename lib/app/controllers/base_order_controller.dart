import 'package:get/get.dart';

abstract class BaseOrderController extends GetxController {
  Future<void> approveTransaction(dynamic orderId);
  Future<void> rejectTransaction(dynamic orderId, {String? reason});
  void showRejectDialog(dynamic orderId);
  Future<void> markOrderReady(dynamic orderId);
}
