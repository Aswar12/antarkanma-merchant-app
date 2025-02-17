// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/order_item_model.dart';
import 'package:antarkanma_merchant/app/data/providers/order_item_provider.dart';

class OrderItemService extends GetxService {
  final OrderItemProvider _orderItemProvider = OrderItemProvider();

  Future<bool> createOrderItem(OrderItemModel orderItem) async {
    try {
      final response =
          await _orderItemProvider.createOrderItem(orderItem.toJson());
      if (response.statusCode == 201) {
        return true; // HTTP 201 Created
      } else {
        Get.snackbar('Error', 'Failed to create order item: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error creating order item: $e');
      Get.snackbar('Error', 'Error creating order item: $e');
      return false;
    }
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final response = await _orderItemProvider.getOrderItems(orderId);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => OrderItemModel.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch order items: ${response.data}');
        return [];
      }
    } catch (e) {
      print('Error getting order items: $e');
      Get.snackbar('Error', 'Error getting order items: $e');
      return [];
    }
  }

  Future<OrderItemModel?> getOrderItemById(String orderItemId) async {
    try {
      final response = await _orderItemProvider.getOrderItemById(orderItemId);
      if (response.statusCode == 200) {
        return OrderItemModel.fromJson(response.data);
      } else {
        Get.snackbar('Error', 'Failed to fetch order item: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error getting order item by ID: $e');
      Get.snackbar('Error', 'Error getting order item by ID: $e');
      return null;
    }
  }
}
