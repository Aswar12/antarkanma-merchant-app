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
          return Container(
            color: context.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _buildProductSection(context, controller),
                ),
                Container(
                  width: 1,
                  color: context.dividerColor,
                ),
                Expanded(
                  flex: 4,
                  child: _buildCartPanel(context, cart, controller),
                ),
              ],
            ),
          );
        } else {
          // ─── Mobile Portrait: Grid + FAB ─────────────
          return Container(
            color: context.backgroundColor,
            child: Stack(
              children: [
                _buildProductSection(context, controller),
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
            ),
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRODUCT SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildProductSection(BuildContext context, PosController controller) {
    return Container(
      color: context.backgroundColor,
      child: Column(
        children: [
          // Search bar (compact)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: controller.onSearchChanged,
                style: primaryTextStyle.copyWith(
                  color: context.textColor,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  hintStyle: TextStyle(
                    color: context.textSecondaryColor.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                    color: context.textSecondaryColor.withOpacity(0.6), size: 20),
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
                  child: CircularProgressIndicator(color: AppColors.orange),
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
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.inventory_2_outlined,
                            size: 36, color: context.textSecondaryColor.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada produk',
                        style: primaryTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambahkan produk di menu Produk',
                        style:
                            TextStyle(fontSize: 13, color: context.textSecondaryColor.withOpacity(0.6)),
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
                        context, controller.products[index], controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Product Card (matches reference design) ────────────

  Widget _buildProductCard(BuildContext context, ProductModel product, PosController controller) {
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
            _showVariantPicker(context, product, controller);
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
            color: context.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isInCart ? AppColors.orange : context.dividerColor,
              width: isInCart ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isInCart
                    ? AppColors.orange.withOpacity(0.15)
                    : context.isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
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
                    color: context.backgroundColor,
                    child: imageUrl != null && product.isValidImageUrl(imageUrl)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _productPlaceholder(context),
                          )
                        : _productPlaceholder(context),
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
                          color: context.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Price
                      Text(
                        _currencyFormat.format(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                      // Add button
                      GestureDetector(
                        onTap: () {
                          if (hasVariants) {
                            _showVariantPicker(context, product, controller);
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
                            color: AppColors.orange.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 16, color: AppColors.orange),
                              const SizedBox(width: 4),
                              const Text(
                                'Tambah',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.orange,
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

  Widget _productPlaceholder(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Center(
        child: Icon(Icons.restaurant_rounded,
            color: context.textSecondaryColor.withOpacity(0.2), size: 36),
      ),
    );
  }

  // ─── Variant Picker ─────────────────────────────────────

  void _showVariantPicker(BuildContext context, ProductModel product, PosController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            ...product.variants.map((variant) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: context.backgroundColor,
                    title: Text(variant.name,
                        style: primaryTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        )),
                    trailing: Text(
                      _currencyFormat
                          .format(product.calculatePriceWithVariant(variant)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
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
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _showMobileCartSheet(context, cart),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.4),
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
                          style: const TextStyle(
                            color: AppColors.orange,
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
      ),
    );
  }

  void _showMobileCartSheet(BuildContext context, PosCartController cart) {
    final controller = Get.find<PosController>();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _buildCartPanel(context, cart, controller),
      ),
      isScrollControlled: true,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CART PANEL (Tablet sidebar + Mobile bottom sheet)
  // ═══════════════════════════════════════════════════════════

  Widget _buildCartPanel(BuildContext context, PosCartController cart, PosController controller) {
    return Container(
      color: context.cardColor,
      child: Column(
        children: [
          // Cart header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.white.withOpacity(0.01) : AppColors.navy.withOpacity(0.03),
              border: Border(
                bottom: BorderSide(color: context.dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: AppColors.navy, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Keranjang (${cart.totalItems})',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
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
          _buildOrderTypeSelector(context, cart),
          // Smart input field - adapts based on order type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Obx(() {
              // Determine which input to show based on order type
              Widget inputField;
              if (cart.orderType.value == 'DINE_IN') {
                inputField = TextField(
                  onChanged: (v) => cart.tableNumber.value = v,
                  style: primaryTextStyle.copyWith(color: context.textColor, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'No. Meja (opsional)',
                    hintStyle: TextStyle(
                        fontSize: 12, color: context.textSecondaryColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.table_bar,
                        size: 16, color: context.textSecondaryColor.withOpacity(0.6)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                  ),
                );
              } else if (cart.orderType.value == 'TAKEAWAY') {
                inputField = TextField(
                  onChanged: (v) => cart.customerName.value = v,
                  style: primaryTextStyle.copyWith(color: context.textColor, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Atas Nama (opsional)',
                    hintStyle: TextStyle(
                        fontSize: 12, color: context.textSecondaryColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.person_outline,
                        size: 16, color: context.textSecondaryColor.withOpacity(0.6)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                  ),
                );
              } else { // DELIVERY
                inputField = TextField(
                  onChanged: (v) => cart.deliveryAddress.value = v,
                  style: primaryTextStyle.copyWith(color: context.textColor, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Alamat pengantaran',
                    hintStyle: TextStyle(
                        fontSize: 12, color: context.textSecondaryColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.location_on,
                        size: 16, color: context.textSecondaryColor.withOpacity(0.6)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                  ),
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
                          size: 48, color: context.textSecondaryColor.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('Keranjang kosong',
                          style: TextStyle(
                              color: context.textSecondaryColor,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Tap produk untuk menambahkan',
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondaryColor.withOpacity(0.6))),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: cart.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (ctx, index) {
                  return _buildCartItem(context, cart.cartItems[index], index, cart);
                },
              );
            }),
          ),
          // Checkout section
          Obx(() {
            if (cart.isCartEmpty) return const SizedBox.shrink();
            return _buildCheckoutSection(context, cart, controller);
          }),
        ],
      ),
    );
  }

  // ─── Order Type Selector ────────────────────────────────

  Widget _buildOrderTypeSelector(BuildContext context, PosCartController cart) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _orderChip(context, 'DINE_IN', 'Dine In', Icons.restaurant,
                  cart.orderType.value, cart),
              const SizedBox(width: 8),
              _orderChip(context, 'TAKEAWAY', 'Takeaway', Icons.takeout_dining,
                  cart.orderType.value, cart),
              const SizedBox(width: 8),
              _orderChip(context, 'DELIVERY', 'Delivery', Icons.delivery_dining,
                  cart.orderType.value, cart),
            ],
          ),
        ));
  }

  Widget _orderChip(BuildContext context, String value, String label, IconData icon, String selected,
      PosCartController cart) {
    final active = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => cart.orderType.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.orange : context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.orange : context.dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.white : context.textSecondaryColor.withOpacity(0.6)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : context.textSecondaryColor.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Cart Item ──────────────────────────────────────────

  Widget _buildCartItem(
      BuildContext context, PosTransactionItemModel item, int index, PosCartController cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
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
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedPrice,
                  style: TextStyle(fontSize: 11, color: context.textSecondaryColor.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          // Quantity
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                _qtyBtn(Icons.remove, () => cart.decrementQuantity(index)),
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: primaryTextStyle.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700, color: context.textColor),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
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
        child: Icon(icon, size: 14, color: AppColors.orange),
      ),
    );
  }

  // ─── Checkout Section ───────────────────────────────────

  Widget _buildCheckoutSection(
      BuildContext context, PosCartController cart, PosController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
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
                      fontSize: 20, fontWeight: FontWeight.w800, color: context.textColor)),
              Text(
                _currencyFormat.format(cart.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
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
                      : () => _showPaymentDialog(context, cart, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.orange.withOpacity(0.5),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
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

  void _showPaymentDialog(
      BuildContext context, PosCartController cart, PosController controller) {
    final amountCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pembayaran',
                      style: primaryTextStyle.copyWith(
                          fontSize: 20, fontWeight: FontWeight.w800, color: context.textColor)),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: context.textSecondaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Total bayar summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.dividerColor),
                ),
                child: Column(
                  children: [
                    Text('Total Bayar',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondaryColor)),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(cart.total),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment method
              Text('Metode Pembayaran',
                  style: primaryTextStyle.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w700, color: context.textColor)),
              const SizedBox(height: 12),
              Obx(() => Row(
                    children: [
                      _paymentMethodChip(context, 'CASH', 'Tunai', Icons.money, cart),
                      const SizedBox(width: 8),
                      _paymentMethodChip(context, 'QRIS', 'QRIS', Icons.qr_code, cart),
                      const SizedBox(width: 8),
                      _paymentMethodChip(
                          context, 'TRANSFER', 'Transfer', Icons.account_balance, cart),
                    ],
                  )),
              const SizedBox(height: 16),

              // Cash input (only if CASH selected)
              Obx(() {
                if (cart.paymentMethod.value != 'CASH') {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uang Diterima',
                        style: primaryTextStyle.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w700, color: context.textColor)),
                    const SizedBox(height: 10),
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
                        color: context.textColor,
                      ),
                      onChanged: (val) {
                        cart.amountPaid.value =
                            double.tryParse(val.replaceAll('.', '')) ?? 0;
                      },
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: primaryTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondaryColor,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondaryColor.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: context.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.orange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (cart.amountPaid.value <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kembalian: ${_currencyFormat.format(cart.changeAmount)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: context.dividerColor),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: context.textColor, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final tx = await controller.submitTransaction();
                        if (tx != null) {
                          _showReceiptDialog(context, tx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Konfirmasi',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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

  Widget _paymentMethodChip(BuildContext context, String value, String label, IconData icon, PosCartController cart) {
    final active = cart.paymentMethod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => cart.paymentMethod.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.orange : context.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.orange : context.dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: active ? Colors.white : context.textSecondaryColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : context.textSecondaryColor),
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

  void _showReceiptDialog(BuildContext context, PosTransactionModel tx) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.green, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.transactionCode ?? '-',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _receiptLine(context, 'Metode', tx.paymentMethodDisplay),
                    _receiptLine(context, 'Tipe', tx.orderTypeDisplay),
                    _receiptLine(context, 'Waktu', tx.formattedDate),
                    const SizedBox(height: 12),
                    Divider(color: context.dividerColor),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bayar',
                            style: primaryTextStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w600, color: context.textColor)),
                        Text(
                          tx.formattedTotal,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (tx.amountPaid > 0) ...[
                      const SizedBox(height: 8),
                      _receiptLine(context, 'Uang Diterima', tx.formattedAmountPaid),
                      _receiptLine(context, 'Kembalian', tx.formattedChangeAmount, color: Colors.green),
                    ],
                  ],
                ),
              ),

              // Printer actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _printOptionBtn(
                      context,
                      icon: Icons.receipt_long,
                      label: 'Struk',
                      color: AppColors.navy,
                      onTap: () => PrintService().printPosReceipt(tx: tx),
                    ),
                    const SizedBox(width: 8),
                    _printOptionBtn(
                      context,
                      icon: Icons.restaurant,
                      label: 'Dapur',
                      color: Colors.orange.shade700,
                      onTap: () => PrintService().printPosKitchenTicket(tx: tx, station: 'DAPUR'),
                    ),
                    const SizedBox(width: 8),
                    _printOptionBtn(
                      context,
                      icon: Icons.settings,
                      label: 'Printer',
                      color: context.textSecondaryColor,
                      onTap: () => PrintService().showPrinterSetupDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Selesai',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _receiptLine(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
          Text(value,
              style: primaryTextStyle.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 13, color: color ?? context.textColor)),
        ],
      ),
    );
  }

  Widget _printOptionBtn(BuildContext context,
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
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
