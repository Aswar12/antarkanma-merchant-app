# Sequence Diagrams

## Flow Pemesanan dan Pengiriman

```
User                    Sistem Antarkanma           Merchant                Kurir
 |                              |                       |                     |
 |   1. Cari Produk             |                       |                     |
 |----------------------------->|                       |                     |
 |   2. Tampilkan Hasil         |                       |                     |
 |<-----------------------------|                       |                     |
 |   3. Pilih Produk            |                       |                     |
 |----------------------------->|                       |                     |
 |   4. Tambah ke Keranjang     |                       |                     |
 |----------------------------->|                       |                     |
 |   5. Tampilkan Keranjang     |                       |                     |
 |<-----------------------------|                       |                     |
 |   6. Checkout                |                       |                     |
 |----------------------------->|                       |                     |
 |   7. Minta Data Pengiriman   |                       |                     |
 |<-----------------------------|                       |                     |
 |   8. Input Data Pengiriman   |                       |                     |
 |----------------------------->|                       |                     |
 |   9. Tampilkan Ringkasan     |                       |                     |
 |<-----------------------------|                       |                     |
 |   10. Konfirmasi Pesanan     |                       |                     |
 |----------------------------->|                       |                     |
 |                              |   11. Kirim Pesanan   |                     |
 |                              |---------------------->|                     |
 |                              |   12. Konfirmasi      |                     |
 |                              |<----------------------|                     |
 |   13. Tampilkan Status       |                       |                     |
 |<-----------------------------|                       |                     |
 |                              |                       |   14. Proses Pesanan|
 |                              |                       |-------------------->|
 |                              |                       |   15. Siap Kirim    |
 |                              |                       |<--------------------|
 |                              |   16. Update Status   |                     |
 |                              |<----------------------|                     |
 |                              |                       |   17. Assign Kurir  |
 |                              |-------------------------------------->|     |
 |                              |                       |   18. Terima Tugas  |
 |                              |<--------------------------------------|     |
 |   19. Update Status Pengiriman|                       |                     |
 |<-----------------------------|                       |                     |
 |   20. Pesanan Diterima       |                       |                     |
 |----------------------------->|                       |                     |
 |                              |   21. Update Status   |                     |
 |                              |---------------------->|                     |
 |                              |                       |   22. Selesai       |
 |                              |-------------------------------------->|     |
 |   23. Minta Review           |                       |                     |
 |<-----------------------------|                       |                     |
 |   24. Kirim Review           |                       |                     |
 |----------------------------->|                       |                     |
```

## Penjelasan Flow

### Pencarian dan Pemilihan Produk (1-5)

1. User mencari produk di aplikasi
2. Sistem menampilkan hasil pencarian
3. User memilih produk yang diinginkan
4. User menambahkan produk ke keranjang
5. Sistem menampilkan keranjang yang diperbarui

### Proses Checkout (6-10)

6. User memulai proses checkout
7. Sistem meminta data pengiriman
8. User memasukkan data pengiriman
9. Sistem menampilkan ringkasan pesanan
10. User mengkonfirmasi pesanan

### Pemrosesan Pesanan (11-16)

11. Sistem mengirim pesanan ke Merchant
12. Merchant mengkonfirmasi pesanan
13. Sistem menampilkan status ke User
14. Merchant memproses pesanan
15. Merchant menandai pesanan siap kirim
16. Sistem menerima update status

### Pengiriman (17-22)

17. Sistem menugaskan Kurir
18. Kurir menerima tugas pengiriman
19. Sistem mengupdate status pengiriman ke User
20. User mengkonfirmasi penerimaan pesanan
21. Sistem mengupdate status ke Merchant
22. Sistem menandai tugas Kurir selesai

### Review (23-24)

23. Sistem meminta review dari User
24. User mengirimkan review

## Catatan Penting

- Setiap langkah melibatkan validasi dan error handling
- Status pesanan diupdate real-time
- Notifikasi dikirim pada setiap perubahan status penting
- Sistem menyimpan log untuk setiap transaksi
- Timeout dan retry mechanism diterapkan untuk setiap request
