import 'package:get/get.dart';

abstract class BaseOrderController extends GetxController {
  Future<void> approveTransaction(dynamic transactionId);
  Future<void> rejectTransaction(dynamic transactionId, {String? reason});
}
