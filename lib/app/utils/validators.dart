class Validators {
  // Validasi untuk identifier (email atau nomor WhatsApp)
  static String? validateIdentifier(String identifier) {
    if (identifier.isEmpty) {
      return 'Silakan masukkan email atau nomor WhatsApp';
    }

    // Validasi email
    if (identifier.contains('@')) {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(identifier)) {
        return 'Format email tidak valid';
      }
    }
    // Validasi nomor WA
    else {
      final phoneRegExp = RegExp(r'^\+?[\d-]{10,13}$');
      if (!phoneRegExp.hasMatch(identifier)) {
        return 'Format nomor telepon tidak valid';
      }
    }
    return null;
  }

  // Validasi untuk email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    // Cek format email menggunakan regex
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Validasi untuk nomor WhatsApp
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor WhatsApp tidak boleh kosong';
    }
    // Cek format nomor WhatsApp menggunakan regex
    String phonePattern = r'^\+?[0-9]{10,15}$'; // Format internasional
    RegExp regex = RegExp(phonePattern);
    if (!regex.hasMatch(value)) {
      return 'Format nomor WhatsApp tidak valid';
    }
    return null;
  }

  // Validasi untuk password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  // Validasi untuk konfirmasi password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }
}
