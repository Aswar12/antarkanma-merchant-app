import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_cart_controller.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/services/print_service.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class PosCashierPage extends StatelessWidget {
  const PosCashierPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();
    final cart = controller.cartController;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 700;

        if (isLandscape) {
          // ─── Tablet Landscape: Split View ────────────
          return Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildProductSection(controller),
              ),
              Container(
                width: 1,
                color: Colors.grey.shade200,
              ),
              Expanded(
                flex: 4,
                child: _buildCartPanel(cart, controller),
              ),
            ],
          );
        } else {
          // ─── Mobile Portrait: Grid + FAB ─────────────
          return Stack(
            children: [
              _buildProductSection(controller),
              // Floating Cart FAB (above bottom nav)
              Positioned(
                bottom: 80, // Above bottom navigation (60 + 20)
                right: 16,
                child: Obx(() {
                  if (cart.isCartEmpty) return const SizedBox.shrink();
                  return _buildCartFab(cart);
                }),
              ),
            ],
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRODUCT SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildProductSection(PosController controller) {
    return Column(
      children: [
        // Search bar (compact)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
        ),
        // Product grid - scrollable when keyboard appears
        Expanded(
          child: Obx(() {
            if (controller.isLoadingProducts.value) {
              return Center(
                child: CircularProgressIndicator(color: dashPrimary),
              );
            }

            if (controller.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 36, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada produk',
                      style: primaryTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tambahkan produk di menu Produk',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(
                      controller.products[index], controller);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Product Card (matches reference design) ────────────

  Widget _buildProductCard(ProductModel product, PosController controller) {
    final hasVariants = product.variants.isNotEmpty;
    final imageUrl =
        product.galleries.isNotEmpty ? product.galleries.first.url : null;

    return Obx(() {
      // Check if product is in cart
      final isInCart = controller.cartController.cartItems.any(
        (item) => item.productId == product.id,
      );

      return GestureDetector(
        onTap: () {
          if (hasVariants) {
            _showVariantPicker(product, controller);
          } else {
            controller.cartController.addProduct(product);
            Get.snackbar(
              'Ditambahkan',
              '${product.name}',
              backgroundColor: Colors.green.withOpacity(0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 1),
              margin: const EdgeInsets.all(12),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isInCart ? dashPrimary : Colors.grey.shade100,
              width: isInCart ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isInCart
                    ? dashPrimary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isInCart ? 12 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with ClipRRect for proper border radius
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: imageUrl != null && product.isValidImageUrl(imageUrl)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _productPlaceholder(),
                          )
                        : _productPlaceholder(),
                  ),
                ),
              ),
              // Info + Button
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        product.name,
                        style: primaryTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Price
                      Text(
                        _currencyFormat.format(product.price),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dashPrimary,
                        ),
                      ),
                      // Add button
                      GestureDetector(
                        onTap: () {
                          if (hasVariants) {
                            _showVariantPicker(product, controller);
                          } else {
                            controller.cartController.addProduct(product);
                            Get.snackbar(
                              'Ditambahkan',
                              '${product.name}',
                              backgroundColor: Colors.green.withOpacity(0.9),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 1),
                              margin: const EdgeInsets.all(12),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: dashPrimary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 16, color: dashPrimary),
                              const SizedBox(width: 4),
                              Text(
                                'Tambah',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: dashPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _productPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.restaurant_rounded,
            color: Colors.grey.shade300, size: 36),
      ),
    );
  }

  // ─── Variant Picker ─────────────────────────────────────

  void _showVariantPicker(ProductModel product, PosController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Varian',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ...product.variants.map((variant) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: Colors.grey.shade50,
                    title: Text(variant.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      _currencyFormat
                          .format(product.calculatePriceWithVariant(variant)),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: dashPrimary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      controller.cartController
                          .addProduct(product, variant: variant);
                      Get.back();
                      Get.snackbar(
                        'Ditambahkan',
                        '${product.name} (${variant.name})',
                        backgroundColor: Colors.green.withOpacity(0.9),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FLOATING CART FAB (Mobile)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCartFab(PosCartController cart) {
    return GestureDetector(
      onTap: () => _showMobileCartSheet(cart),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: dashPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dashPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 28),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Obx(() => Text(
                        '${cart.totalItems}',
                        style: TextStyle(
                          color: dashPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileCartSheet(PosCartController cart) {
    final controller = Get.find<PosController>();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _buildCartPanel(cart, controller),
      ),
      isScrollControlled: true,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CART PANEL (Tablet sidebar + Mobile bottom sheet)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCartPanel(PosCartController cart, PosController controller) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cart header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dashNavyDeep.withOpacity(0.03),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            color: dashNavyDeep, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Keranjang (${cart.totalItems})',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )),
                Obx(() {
                  if (cart.isCartEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: cart.clearCart,
                    child: Text('Hapus',
                        style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  );
                }),
              ],
            ),
          ),
          // Order type
          _buildOrderTypeSelector(cart),
          // Smart input field - adapts based on order type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Obx(() {
              // Determine which input to show based on order type
              Widget inputField;
              if (cart.orderType.value == 'DINE_IN') {
                inputField = TextField(
                  onChanged: (v) => cart.tableNumber.value = v,
                  decoration: InputDecoration(
                    hintText: 'No. Meja (opsional)',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.table_bar,
                        size: 16, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                );
              } else if (cart.orderType.value == 'TAKEAWAY') {
                inputField = TextField(
                  onChanged: (v) => cart.customerName.value = v,
                  decoration: InputDecoration(
                    hintText: 'Atas Nama (opsional)',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.person_outline,
                        size: 16, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                );
              } else { // DELIVERY
                inputField = TextField(
                  onChanged: (v) => cart.deliveryAddress.value = v,
                  decoration: InputDecoration(
                    hintText: 'Alamat pengantaran',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                );
              }
              
              return SizedBox(
                height: 36,
                child: inputField,
              );
            }),
          ),
          // Cart items
          Expanded(
            child: Obx(() {
              if (cart.isCartEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 48, color: Colors.grey.shade200),
                      const SizedBox(height: 12),
                      Text('Keranjang kosong',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Tap produk untuk menambahkan',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade300)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: cart.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  return _buildCartItem(cart.cartItems[index], index, cart);
                },
              );
            }),
          ),
          // Checkout section
          Obx(() {
            if (cart.isCartEmpty) return const SizedBox.shrink();
            return _buildCheckoutSection(cart, controller);
          }),
        ],
      ),
    );
  }

  // ─── Order Type Selector ────────────────────────────────

  Widget _buildOrderTypeSelector(PosCartController cart) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _orderChip('DINE_IN', 'Dine In', Icons.restaurant,
                  cart.orderType.value, cart),
              const SizedBox(width: 8),
              _orderChip('TAKEAWAY', 'Takeaway', Icons.takeout_dining,
                  cart.orderType.value, cart),
              const SizedBox(width: 8),
              _orderChip('DELIVERY', 'Delivery', Icons.delivery_dining,
                  cart.orderType.value, cart),
            ],
          ),
        ));
  }

  Widget _orderChip(String value, String label, IconData icon, String selected,
      PosCartController cart) {
    final active = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => cart.orderType.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? dashPrimary : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? dashPrimary : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.white : Colors.grey.shade500),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Cart Item ──────────────────────────────────────────

  Widget _buildCartItem(
      PosTransactionItemModel item, int index, PosCartController cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: primaryTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedPrice,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Quantity
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _qtyBtn(Icons.remove, () => cart.decrementQuantity(index)),
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                _qtyBtn(Icons.add, () => cart.incrementQuantity(index)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.formattedSubtotal,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: dashPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: dashPrimary),
      ),
    );
  }

  // ─── Checkout Section ───────────────────────────────────

  Widget _buildCheckoutSection(
      PosCartController cart, PosController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: primaryTextStyle.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              Text(
                _currencyFormat.format(cart.total),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: dashPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => _showPaymentDialog(cart, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dashPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: dashPrimary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isProcessing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment_rounded, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Bayar Sekarang',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                  )),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PAYMENT DIALOG
  // ═══════════════════════════════════════════════════════════

  void _showPaymentDialog(PosCartController cart, PosController controller) {
    final amountCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pembayaran',
                  style: primaryTextStyle.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dashPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Total Bayar',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(cart.total),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: dashPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment method
              Text('Metode Pembayaran',
                  style: primaryTextStyle.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      _payChip('CASH', 'Tunai', Icons.money, cart),
                      const SizedBox(width: 8),
                      _payChip('QRIS', 'QRIS', Icons.qr_code, cart),
                      const SizedBox(width: 8),
                      _payChip(
                          'TRANSFER', 'Transfer', Icons.account_balance, cart),
                    ],
                  )),
              const SizedBox(height: 16),

              // Cash input
              Obx(() {
                if (cart.paymentMethod.value != 'CASH') {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uang Diterima',
                        style: primaryTextStyle.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandSeparatorFormatter(),
                      ],
                      style: primaryTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: primaryTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: dashPrimary, width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        cart.amountPaid.value =
                            double.tryParse(val.replaceAll('.', '')) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (cart.amountPaid.value <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kembalian: ${_currencyFormat.format(cart.changeAmount)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final result = await controller.submitTransaction();
                        if (result != null) {
                          _showReceiptDialog(result);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dashPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Konfirmasi',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payChip(
      String value, String label, IconData icon, PosCartController cart) {
    final active = cart.paymentMethod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => cart.paymentMethod.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? dashPrimary : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? dashPrimary : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: active ? Colors.white : Colors.grey.shade500),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RECEIPT DIALOG
  // ═══════════════════════════════════════════════════════════

  void _showReceiptDialog(PosTransactionModel tx) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    color: Colors.green.shade600, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Transaksi Berhasil!',
                style: primaryTextStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                tx.transactionCode ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              _receiptLine('Tipe', tx.orderTypeDisplay),
              _receiptLine('Bayar', tx.paymentMethodDisplay),
              _receiptLine('Items', '${tx.totalItems} item'),
              Divider(color: Colors.grey.shade200, height: 20),
              _receiptLine('Total', tx.formattedTotal,
                  isBold: true, color: dashPrimary),
              if (tx.amountPaid > 0)
                _receiptLine('Dibayar', tx.formattedAmountPaid),
              if (tx.changeAmount > 0)
                _receiptLine('Kembalian', tx.formattedChangeAmount,
                    color: Colors.green.shade600),
              const SizedBox(height: 16),
              // Print buttons row
              Row(
                children: [
                  _printOptionBtn(
                    icon: Icons.receipt_long,
                    label: 'Struk',
                    color: dashNavyDeep,
                    onTap: () {
                      final printService = PrintService();
                      printService.printPosReceipt(tx: tx);
                    },
                  ),
                  const SizedBox(width: 8),
                  _printOptionBtn(
                    icon: Icons.restaurant,
                    label: 'Dapur',
                    color: Colors.orange.shade700,
                    onTap: () {
                      final printService = PrintService();
                      printService.printPosKitchenTicket(
                        tx: tx,
                        station: 'DAPUR',
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _printOptionBtn(
                    icon: Icons.local_bar,
                    label: 'Bar',
                    color: Colors.purple.shade600,
                    onTap: () {
                      final printService = PrintService();
                      printService.printPosKitchenTicket(
                        tx: tx,
                        station: 'BAR',
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _printOptionBtn(
                    icon: Icons.settings_bluetooth,
                    label: 'Printer',
                    color: Colors.grey.shade600,
                    onTap: () {
                      final printService = PrintService();
                      printService.showPrinterSetupDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dashPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Selesai',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptLine(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _printOptionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderTypeChip(String label, String value, PosCartController cart) {
    final active = cart.orderType.value == value;
    return GestureDetector(
      onTap: () => cart.orderType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? dashPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/// Formats numeric input with thousand separators (dots)
/// e.g., 150000 → 150.000
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Remove existing separators
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue;

    // Format with dots as thousand separators
    final result = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(digits[i]);
    }

    final formatted = result.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
