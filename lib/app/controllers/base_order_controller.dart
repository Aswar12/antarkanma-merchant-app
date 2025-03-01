import 'package:get/get.dart';
import '../services/merchant_service.dart';

abstract class BaseOrderController extends GetxController {
  final merchantService = Get.find<MerchantService>();
  
  // Order summary state variables
  final totalPending = 0.obs;
  final totalProcessing = 0.obs;
  final totalReadyForPickup = 0.obs;
  final totalPickedUp = 0.obs;
  final totalCompleted = 0.obs;
  final totalWaitingApproval = 0.obs;

  Future<void> fetchOrderSummary();

  Future<void> approveTransaction(dynamic orderId);
  Future<void> rejectTransaction(dynamic orderId, {String? reason});
  void showRejectDialog(dynamic orderId);
  Future<void> markOrderReady(dynamic orderId);
}
