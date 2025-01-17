import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class MerchantInfoSection extends StatelessWidget {
  final ProductModel product;

  const MerchantInfoSection({
    Key? key,
    required this.product,
  }) : super(key: key);

  String _getOperatingHours() {
    final merchant = product.merchant;
    if (merchant?.openingTime == null || merchant?.closingTime == null) {
      return 'Jam operasional tidak tersedia';
    }
    return '${merchant!.openingTime} - ${merchant.closingTime}';
  }

  String _getOperatingDays() {
    final merchant = product.merchant;
    if (merchant?.operatingDays == null || merchant!.operatingDays!.isEmpty) {
      return 'Hari operasional tidak tersedia';
    }
    return merchant.operatingDays!.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final merchant = product.merchant;
    if (merchant == null) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimenssions.width20,
        vertical: Dimenssions.height10,
      ),
      padding: EdgeInsets.all(Dimenssions.height20),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (merchant.logo != null && merchant.logo!.isNotEmpty)
                Container(
                  width: Dimenssions.height50,
                  height: Dimenssions.height50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(merchant.logo!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(Dimenssions.height12),
                  decoration: BoxDecoration(
                    color: logoColorSecondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    color: logoColorSecondary,
                    size: 24,
                  ),
                ),
              SizedBox(width: Dimenssions.width16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            merchant.name,
                            style: primaryTextStyle.copyWith(
                              fontSize: Dimenssions.font16,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width8,
                            vertical: Dimenssions.height4,
                          ),
                          decoration: BoxDecoration(
                            color: merchant.isActive
                                ? Colors.green.withOpacity(0.1)
                                : alertColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimenssions.radius8),
                          ),
                          child: Text(
                            merchant.isActive ? 'Buka' : 'Tutup',
                            style: primaryTextStyle.copyWith(
                              fontSize: Dimenssions.font12,
                              color: merchant.isActive ? Colors.green : alertColor,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimenssions.height4),
                    Text(
                      merchant.address,
                      style: secondaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (merchant.description != null && merchant.description!.isNotEmpty) ...[
            SizedBox(height: Dimenssions.height12),
            Text(
              merchant.description!,
              style: secondaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
                height: 1.5,
              ),
            ),
          ],
          SizedBox(height: Dimenssions.height16),
          Container(
            padding: EdgeInsets.all(Dimenssions.height12),
            decoration: BoxDecoration(
              color: backgroundColor3.withOpacity(0.3),
              borderRadius: BorderRadius.circular(Dimenssions.radius12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: logoColorSecondary,
                      size: 20,
                    ),
                    SizedBox(width: Dimenssions.width8),
                    Expanded(
                      child: Text(
                        _getOperatingHours(),
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimenssions.height8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: logoColorSecondary,
                      size: 20,
                    ),
                    SizedBox(width: Dimenssions.width8),
                    Expanded(
                      child: Text(
                        _getOperatingDays(),
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (merchant.productCount != null) ...[
                  SizedBox(height: Dimenssions.height8),
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: logoColorSecondary,
                        size: 20,
                      ),
                      SizedBox(width: Dimenssions.width8),
                      Text(
                        '${merchant.productCount} Produk',
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (merchant.id != null) {
                      Get.toNamed('/chat', arguments: {
                        'merchantId': merchant.id,
                        'merchantName': merchant.name,
                      });
                    }
                  },
                  icon: Icon(Icons.chat_outlined, color: logoColorSecondary),
                  label: Text(
                    'Chat Penjual',
                    style: primaryTextOrange,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: logoColorSecondary,
                    side: BorderSide(color: logoColorSecondary),
                    padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimenssions.width12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final phoneNumber = merchant.phoneNumber;
                    if (phoneNumber.isNotEmpty) {
                      final url = 'tel:$phoneNumber';
                      if (await url_launcher.canLaunch(url)) {
                        await url_launcher.launch(url);
                      }
                    }
                  },
                  icon: Icon(Icons.phone_outlined, color: logoColorSecondary),
                  label: Text(
                    'Hubungi',
                    style: primaryTextOrange,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: logoColorSecondary,
                    side: BorderSide(color: logoColorSecondary),
                    padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
