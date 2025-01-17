import 'package:antarkanma_merchant/app/services/user_location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/controllers/user_location_controller.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/theme.dart';

class AddressSelectionPage extends StatelessWidget {
  final UserLocationController controller =
      Get.put(UserLocationController(locationService: UserLocationService()));

  AddressSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Dimenssions.height100),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor1,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Pilih Alamat',
                    style: primaryTextStyle.copyWith(
                      fontSize: Dimenssions.font18,
                      fontWeight: semiBold,
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: Dimenssions.width15),
                      child: IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(Dimenssions.height5),
                          decoration: BoxDecoration(
                            color: logoColorSecondary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius15),
                          ),
                          child: Icon(
                            Icons.add,
                            color: logoColorSecondary,
                            size: Dimenssions.height22,
                          ),
                        ),
                        onPressed: () => Get.toNamed('/main/add-address'),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimenssions.width15,
                    vertical: Dimenssions.height5,
                  ),
                  child: Text(
                    'Pilih alamat pengiriman untuk pesanan Anda',
                    style: secondaryTextStyle.copyWith(
                      fontSize: Dimenssions.font14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: logoColorSecondary,
            ),
          );
        }

        if (controller.userLocations.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(Dimenssions.height15),
          itemCount: controller.userLocations.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.userLocations.length) {
              return SizedBox(height: Dimenssions.height20);
            }
            final address = controller.userLocations[index];
            return _buildAddressItem(address);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: Dimenssions.height100,
            height: Dimenssions.height100,
            decoration: BoxDecoration(
              color: backgroundColor3,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off,
              size: Dimenssions.height45,
              color: secondaryTextColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: Dimenssions.height20),
          Text(
            'Belum ada alamat tersimpan',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font18,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimenssions.width30),
            child: Text(
              'Tambahkan alamat untuk memudahkan pengiriman pesanan Anda',
              style: secondaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Dimenssions.height30),
          Container(
            height: Dimenssions.height45,
            padding: EdgeInsets.symmetric(horizontal: Dimenssions.width30),
            child: TextButton(
              onPressed: () => Get.toNamed('/usermain/add-address'),
              style: TextButton.styleFrom(
                backgroundColor: logoColorSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_location,
                    color: backgroundColor1,
                    size: Dimenssions.height22,
                  ),
                  SizedBox(width: Dimenssions.width10),
                  Text(
                    'Tambah Alamat Baru',
                    style: primaryTextStyle.copyWith(
                      color: backgroundColor1,
                      fontSize: Dimenssions.font14,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(UserLocationModel address) {
    final isSelected = controller.selectedLocation.value?.id == address.id;

    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height15),
      decoration: BoxDecoration(
        color: backgroundColor2,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        border: Border.all(
          color: isSelected ? logoColorSecondary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor6.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: backgroundColor6.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectLocation(address);
            Get.back(result: address);
          },
          borderRadius: BorderRadius.circular(Dimenssions.radius15),
          child: Container(
            padding: EdgeInsets.all(Dimenssions.height15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Dimenssions.height22,
                  height: Dimenssions.height22,
                  margin: EdgeInsets.only(
                    top: Dimenssions.height5,
                    right: Dimenssions.width15,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? logoColorSecondary
                          : secondaryTextColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: Dimenssions.height10,
                            height: Dimenssions.height10,
                            decoration: BoxDecoration(
                              color: logoColorSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.customerName ?? 'Alamat ${address.id}',
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimenssions.font16,
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width10,
                                vertical: Dimenssions.height5,
                              ),
                              decoration: BoxDecoration(
                                color: logoColorSecondary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(Dimenssions.radius15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: logoColorSecondary,
                                    size: Dimenssions.height15,
                                  ),
                                  SizedBox(width: Dimenssions.width5),
                                  Text(
                                    'Utama',
                                    style: primaryTextStyle.copyWith(
                                      color: logoColorSecondary,
                                      fontSize: Dimenssions.font12,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: Dimenssions.height10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: logoColorSecondary,
                            size: Dimenssions.height15,
                          ),
                          SizedBox(width: Dimenssions.width5),
                          Expanded(
                            child: Text(
                              address.fullAddress,
                              style: secondaryTextStyle.copyWith(
                                fontSize: Dimenssions.font14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimenssions.height10),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: logoColorSecondary,
                            size: Dimenssions.height15,
                          ),
                          SizedBox(width: Dimenssions.width5),
                          Text(
                            address.phoneNumber,
                            style: secondaryTextStyle.copyWith(
                              fontSize: Dimenssions.font14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimenssions.height10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width10,
                          vertical: Dimenssions.height5,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor3,
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label,
                              color: secondaryTextColor,
                              size: Dimenssions.height15,
                            ),
                            SizedBox(width: Dimenssions.width5),
                            Text(
                              address.addressType,
                              style: secondaryTextStyle.copyWith(
                                fontSize: Dimenssions.font12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
