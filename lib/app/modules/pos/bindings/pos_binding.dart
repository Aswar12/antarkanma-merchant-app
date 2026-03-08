import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_cart_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosCartController>(() => PosCartController());
    Get.lazyPut<PosController>(() => PosController());
  }
}
