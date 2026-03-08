import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';

class PosCartController extends GetxController {
  final cartItems = <PosTransactionItemModel>[].obs;
  final orderType = 'DINE_IN'.obs;
  final paymentMethod = 'CASH'.obs;
  final customerName = ''.obs;
  final customerPhone = ''.obs;
  final deliveryAddress = ''.obs;
  final tableNumber = ''.obs;
  final notes = ''.obs;
  final discount = 0.0.obs;
  final tax = 0.0.obs;
  final amountPaid = 0.0.obs;

  // ─── Computed Values ─────────────────────────────────────

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => subtotal - discount.value + tax.value;

  double get changeAmount =>
      amountPaid.value > total ? amountPaid.value - total : 0;

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isCartEmpty => cartItems.isEmpty;

  // ─── Cart Operations ────────────────────────────────────

  void addProduct(ProductModel product, {VariantModel? variant}) {
    final existingIndex = cartItems.indexWhere((item) {
      if (variant != null) {
        return item.productId == product.id &&
            item.productVariantId == variant.id;
      }
      return item.productId == product.id && item.productVariantId == null;
    });

    if (existingIndex >= 0) {
      // Increase quantity
      final existing = cartItems[existingIndex];
      cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      // Add new item
      final price = variant != null
          ? product.calculatePriceWithVariant(variant)
          : product.price;
      final name =
          variant != null ? '${product.name} (${variant.name})' : product.name;

      cartItems.add(PosTransactionItemModel(
        productId: product.id,
        productVariantId: variant?.id,
        name: name,
        quantity: 1,
        price: price,
      ));
    }
  }

  void addCustomItem(String name, double price, {int quantity = 1}) {
    cartItems.add(PosTransactionItemModel(
      name: name,
      quantity: quantity,
      price: price,
    ));
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    cartItems[index] = cartItems[index].copyWith(quantity: quantity);
  }

  void incrementQuantity(int index) {
    final item = cartItems[index];
    cartItems[index] = item.copyWith(quantity: item.quantity + 1);
  }

  void decrementQuantity(int index) {
    final item = cartItems[index];
    if (item.quantity <= 1) {
      removeItem(index);
    } else {
      cartItems[index] = item.copyWith(quantity: item.quantity - 1);
    }
  }

  void updateItemNotes(int index, String? notes) {
    cartItems[index] = cartItems[index].copyWith(notes: notes);
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  void clearCart() {
    cartItems.clear();
    orderType.value = 'DINE_IN';
    paymentMethod.value = 'CASH';
    customerName.value = '';
    customerPhone.value = '';
    deliveryAddress.value = '';
    tableNumber.value = '';
    notes.value = '';
    discount.value = 0;
    tax.value = 0;
    amountPaid.value = 0;
  }

  // ─── Build Transaction Data ─────────────────────────────

  Map<String, dynamic> buildTransactionData() {
    return {
      'order_type': orderType.value,
      'payment_method': paymentMethod.value,
      'items': cartItems.map((item) => item.toJson()).toList(),
      if (customerName.value.isNotEmpty) 'customer_name': customerName.value,
      if (customerPhone.value.isNotEmpty) 'customer_phone': customerPhone.value,
      if (deliveryAddress.value.isNotEmpty)
        'delivery_address': deliveryAddress.value,
      if (tableNumber.value.isNotEmpty) 'table_number': tableNumber.value,
      'discount': discount.value,
      'tax': tax.value,
      if (amountPaid.value > 0) 'amount_paid': amountPaid.value,
      if (notes.value.isNotEmpty) 'notes': notes.value,
    };
  }
}
