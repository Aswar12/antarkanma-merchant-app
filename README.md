# Antarkanma

Antarkanma adalah aplikasi e-commerce yang mendukung multi-merchant, memungkinkan pengguna untuk memesan makanan dan barang dari berbagai merchant dengan mudah. Sistem ini dirancang untuk memberikan pengalaman pengguna yang optimal melalui fitur-fitur yang lengkap dan intuitif.

## Fitur Utama

- **Multi-Merchant Support**: Sistem mendukung multi-merchant, memungkinkan satu pesanan mencakup produk dari berbagai merchant.
- **Manajemen Produk**: Produk terkait dengan kategori dan merchant, serta galeri produk memungkinkan penambahan gambar multiple untuk setiap produk.
- **Sistem Pemesanan**: Orders menyimpan informasi pesanan keseluruhan, sedangkan Order_Items menyimpan detail item dalam pesanan.
- **Transaksi dan Pembayaran**: Transactions menyimpan informasi pembayaran dan status, mendukung berbagai metode pembayaran (manual dan online).
- **Sistem Pengiriman**: Deliveries melacak status pengiriman untuk setiap transaksi, dengan Courier_Batches memungkinkan pengelompokan pengiriman untuk efisiensi.
- **Manajemen Pengguna**: Users dapat memiliki peran berbeda (USER, MERCHANT, COURIER), dengan User_Locations mendukung penyimpanan beberapa alamat untuk setiap pengguna.
- **Sistem Loyalitas**: Loyalty_Points memungkinkan implementasi sistem loyalitas pelanggan.
- **Ulasan Produk**: Product_Reviews memungkinkan pengguna memberikan ulasan dan rating untuk produk.

## Dokumentasi

Dokumentasi lengkap dapat ditemukan di folder `docs/`:

- Database Schema dan ERD: `docs/database/`
- Fitur per Role: `docs/features/`
- Diagram Sistem: `docs/diagrams/`
- Spesifikasi Teknis: `docs/technical/`
