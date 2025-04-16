import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:flutter/services.dart';

class AddOperationalHoursBottomSheet extends StatefulWidget {
  const AddOperationalHoursBottomSheet({super.key});

  @override
  State<AddOperationalHoursBottomSheet> createState() =>
      _AddOperationalHoursBottomSheetState();
}

class _AddOperationalHoursBottomSheetState
    extends State<AddOperationalHoursBottomSheet> {
  final MerchantProfileController profileController = Get.find<MerchantProfileController>();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();

  final List<String> daysOfWeek = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  final RxSet<String> selectedDays = <String>{}.obs; // Changed to Set to prevent duplicates
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if available
    final merchant = profileController.merchant;
    if (merchant != null) {
      if (merchant.openingTime != null) {
        openingTimeController.text = merchant.openingTime!;
        profileController.openingTimeController.text = merchant.openingTime!;
      }
      if (merchant.closingTime != null) {
        closingTimeController.text = merchant.closingTime!;
        profileController.closingTimeController.text = merchant.closingTime!;
      }
      if (merchant.operatingDays != null) {
        // Convert to title case for display and ensure uniqueness
        final days = merchant.operatingDays!.map((day) {
          return day[0].toUpperCase() + day.substring(1).toLowerCase();
        }).toSet(); // Convert to Set to remove duplicates
        selectedDays.value = days;
        profileController.operatingDays.value = days.toList();
      }
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    // Parse existing time if available
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(':');
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        print('Error parsing time: $e');
      }
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: logoColor,
            colorScheme: ColorScheme.light(primary: logoColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formattedTime;
      });
      
      // Update controller values
      if (controller == openingTimeController) {
        profileController.openingTimeController.text = formattedTime;
      } else if (controller == closingTimeController) {
        profileController.closingTimeController.text = formattedTime;
      }
    }
  }

  Future<void> _saveOperationalHours() async {
    if (openingTimeController.text.isEmpty || closingTimeController.text.isEmpty) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Mohon isi jam buka dan jam tutup',
        isError: true,
      );
      return;
    }

    if (selectedDays.isEmpty) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Mohon pilih minimal satu hari operasional',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Update controller values
      profileController.openingTimeController.text = openingTimeController.text;
      profileController.closingTimeController.text = closingTimeController.text;
      profileController.operatingDays.value = selectedDays.toList(); // Convert Set to List

      // Call the update method
      await profileController.updateOperatingHours();
      
      // Force refresh the profile page
      profileController.update(['merchant_profile']);
      
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _toggleDay(String day, bool selected) {
    setState(() {
      if (selected) {
        // Check if the day is already selected (shouldn't happen with Set, but just in case)
        if (selectedDays.contains(day)) {
          showCustomSnackbar(
            title: 'Perhatian',
            message: 'Hari $day sudah dipilih',
            isError: true,
          );
          return;
        }
        
        // Add the day if we haven't reached the maximum
        if (selectedDays.length >= 7) {
          showCustomSnackbar(
            title: 'Perhatian',
            message: 'Maksimal 7 hari dapat dipilih',
            isError: true,
          );
          return;
        }
        selectedDays.add(day);
      } else {
        selectedDays.remove(day);
      }
      
      // Update controller immediately
      profileController.operatingDays.value = selectedDays.toList();
      profileController.update(['merchant_profile']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor1,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimenssions.radius15),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Atur Jam Operasional',
                style: primaryTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              GestureDetector(
                onTap: () => _selectTime(context, openingTimeController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: openingTimeController,
                    decoration: InputDecoration(
                      labelText: 'Jam Buka',
                      suffixIcon: Icon(Icons.access_time, color: logoColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: logoColor),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectTime(context, closingTimeController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: closingTimeController,
                    decoration: InputDecoration(
                      labelText: 'Jam Tutup',
                      suffixIcon: Icon(Icons.access_time, color: logoColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: logoColor),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Pilih Hari Buka:',
                style: primaryTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: daysOfWeek.map((day) {
                  return FilterChip(
                    label: Text(day),
                    selected: selectedDays.contains(day),
                    onSelected: (selected) => _toggleDay(day, selected),
                    selectedColor: logoColor.withOpacity(0.2),
                    checkmarkColor: logoColor,
                    labelStyle: TextStyle(
                      color: selectedDays.contains(day) ? logoColor : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : _saveOperationalHours,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    openingTimeController.dispose();
    closingTimeController.dispose();
    super.dispose();
  }
}
