// ignore_for_file: unused_field, unnecessary_null_comparison, library_private_types_in_public_api, deprecated_member_use

import 'package:antarkanma_merchant/app/modules/user/views/map_picker_page.dart';
import 'package:antarkanma_merchant/app/widgets/custom_input_field.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/controllers/user_location_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:latlong2/latlong.dart';

class AddEditAddressPage extends GetView<UserLocationController> {
  final UserLocationModel? address = Get.arguments;

  AddEditAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = address != null;
    return Scaffold(
      backgroundColor: backgroundColor8,
      appBar: AppBar(
        iconTheme: IconThemeData(color: logoColorSecondary),
        backgroundColor: transparentColor,
        title: Text(
          isEditing ? 'Edit Alamat' : 'Tambah Alamat',
          style: primaryTextStyle,
        ),
      ),
      body: AddressForm(address: address),
    );
  }
}

class AddressForm extends StatefulWidget {
  final UserLocationModel? address;

  const AddressForm({super.key, this.address});

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  String _selectedAddressType = UserLocationModel.TYPE_RUMAH;
  bool _isDefault = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late TextEditingController _notesController;

  // Tambahkan controller dan variabel untuk dropdown
  late TextEditingController _postalCodeController;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;

  // Data untuk dropdown
  final List<String> provinces = ['SULAWESI SELATAN'];
  final List<String> cities = ['PANGKAJENE KEPULAUAN'];
  final List<String> districts = [
    'MANDALLE',
    'MARANG',
    'SEGERI',
  ];

  final UserLocationController controller = Get.find<UserLocationController>();
  bool _isFocused = false; // Tambahkan di bagian deklarasi variabel state
  @override
  void initState() {
    super.initState();
    _customerNameController =
        TextEditingController(text: widget.address?.customerName);
    _addressController = TextEditingController(text: widget.address?.address);
    _phoneNumberController =
        TextEditingController(text: widget.address?.phoneNumber);
    _selectedAddressType =
        widget.address?.addressType ?? UserLocationModel.TYPE_RUMAH;
    _isDefault = widget.address?.isDefault ?? false;
    _latitude = widget.address?.latitude ?? 0.0;
    _longitude = widget.address?.longitude ?? 0.0;
    _notesController = TextEditingController(text: widget.address?.notes);
    _postalCodeController =
        TextEditingController(text: widget.address?.postalCode);

    // Inisialisasi nilai dropdown
    _selectedCity = widget.address?.city ?? cities[0];
    _selectedDistrict = widget.address?.district;
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null ? logoColorSecondary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Image.asset(
                  'assets/icon_your_address.png',
                  width: 17,
                  color: value != null ? logoColorSecondary : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: backgroundColor2,
                      value: value,
                      items: items.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: primaryTextStyle,
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: value != null ? logoColorSecondary : Colors.grey,
                      ),
                      isExpanded: true,
                      hint: Text(
                        hintText,
                        style: subtitleTextStyle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Personal Information Section
          Text(
            'Informasi Penerima',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                CustomInputField(
                  label: 'Nama Penerima',
                  hintText: 'Masukkan nama penerima',
                  controller: _customerNameController,
                  validator: (value) =>
                      value!.isEmpty ? 'Nama penerima harus diisi' : null,
                  icon: 'assets/icon_name.png',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Nomor Telepon',
                  hintText: 'Masukkan nomor telepon',
                  controller: _phoneNumberController,
                  validator: (value) =>
                      value!.isEmpty ? 'Nomor telepon harus diisi' : null,
                  icon: const Icon(Icons.phone_android_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          // Address Information Section
          Text(
            'Informasi Alamat',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Kecamatan',
                  value: _selectedDistrict,
                  items: districts,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                  hintText: 'Pilih Kecamatan',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Alamat Lengkap',
                  hintText: 'Masukkan alamat lengkap',
                  controller: _addressController,
                  validator: (value) =>
                      value!.isEmpty ? 'Alamat harus diisi' : null,
                  icon: 'assets/icon_your_address.png',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Kode Pos',
                  hintText: 'Masukkan kode pos',
                  controller: _postalCodeController,
                  validator: (value) {
                    if (value!.isEmpty) return 'Kode pos harus diisi';
                    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                      return 'Kode pos harus 5 digit';
                    }
                    return null;
                  },
                  icon: const Icon(Icons.local_post_office_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Catatan Alamat',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: Dimenssions
                      .height90, // Tinggi yang lebih besar untuk multiple lines

                  decoration: BoxDecoration(
                    color: backgroundColor2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_isFocused || _notesController.text.isNotEmpty)
                          ? logoColorSecondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align to top
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Image.asset(
                          'assets/icon_your_address.png',
                          width: 17,
                          color:
                              (_isFocused || _notesController.text.isNotEmpty)
                                  ? logoColorSecondary
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _isFocused = hasFocus;
                            });
                          },
                          child: TextFormField(
                            style: primaryTextStyle,
                            controller: _notesController,
                            maxLines: 4, // Memungkinkan 4 baris text
                            decoration: InputDecoration(
                              hintText:
                                  'Contoh: Rumah cat putih, pagar hitam, dekat masjid',
                              hintStyle: subtitleTextStyle,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.only(top: 16, right: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Tipe Alamat',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAddressType != null
                          ? logoColorSecondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_city, // atau icon lain yang sesuai
                        size: 17,
                        color: _selectedAddressType != null
                            ? logoColorSecondary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: backgroundColor2,
                            value: _selectedAddressType,
                            items: UserLocationModel.addressTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: primaryTextStyle,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAddressType = value!;
                              });
                            },
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: _selectedAddressType != null
                                  ? logoColorSecondary
                                  : Colors.grey,
                            ),
                            isExpanded: true,
                            hint: Text(
                              'Pilih tipe alamat',
                              style: subtitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Checkbox(
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value!;
                });
              },
              activeColor: Colors.black, // Warna latar belakang saat dicentang
              checkColor: logoColorSecondary, // Warna tanda centang
              fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.black; // Warna latar belakang saat dicentang
                }
                return Colors.black
                    .withOpacity(0.6); // Warna border saat tidak dicentang
              }),
            ),
            title: Text(
              'Jadikan Alamat Utama',
              style: primaryTextStyle,
            ),
            tileColor: backgroundColor1,
            onTap: () {
              setState(() {
                _isDefault = !_isDefault;
              });
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final result =
                            await Get.to(() => const MapPickerView());
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _latitude = (result['location'] as LatLng).latitude;
                            _longitude =
                                (result['location'] as LatLng).longitude;
                            _addressController.text =
                                result['address'] as String;
                          });
                        }
                      } catch (e) {
                        showCustomSnackbar(
                          title: 'Error',
                          message: 'Gagal memilih lokasi',
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _latitude != 0.0 && _longitude != 0.0
                              ? Icons.check_circle
                              : Icons.location_on,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _latitude != 0.0 && _longitude != 0.0
                              ? 'Lokasi Telah Dipilih'
                              : 'Pilih Lokasi dari Peta',
                          style: primaryTextOrange,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoColorSecondary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.address == null
                              ? Icons.add_location_alt
                              : Icons.save_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.address == null
                              ? 'Tambah Alamat'
                              : 'Simpan Perubahan',
                          style: primaryTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      showCustomSnackbar(
        title: 'Peringatan',
        message: 'Mohon lengkapi semua field yang wajib diisi',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Check district selection
    if (_selectedDistrict == null) {
      showCustomSnackbar(
        title: 'Peringatan',
        message: 'Mohon pilih kecamatan',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Check location selection
    if (_latitude == 0.0 || _longitude == 0.0) {
      showCustomSnackbar(
        title: 'Peringatan',
        message: 'Silakan pilih lokasi dari peta',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final newAddress = UserLocationModel(
        id: widget.address?.id,
        userId: widget.address?.userId ?? 0,
        customerName: _customerNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _selectedCity!,
        district: _selectedDistrict!,
        postalCode: _postalCodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        phoneNumber: _phoneNumberController.text.trim(),
        addressType: _selectedAddressType,
        isDefault: _isDefault,
        notes: _notesController.text.trim(),
      );

      bool success = await Get.showOverlay(
        asyncFunction: () async {
          return widget.address == null
              ? await controller.addAddress(newAddress)
              : await controller.updateAddress(newAddress);
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (success) {
        showCustomSnackbar(
          title: 'Sukses',
          message: widget.address == null
              ? 'Alamat berhasil ditambahkan'
              : 'Alamat berhasil diperbarui',
          backgroundColor: Colors.green,
        );
        // Close the page after successful submission
        Get.back();
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Terjadi kesalahan saat menyimpan alamat',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
