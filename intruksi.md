# Antarkanma

Antarkanma adalah aplikasi e-commerce yang mendukung multi-merchant, memungkinkan pengguna untuk memesan makanan dan barang dari berbagai merchant dengan mudah. Sistem ini dirancang untuk memberikan pengalaman pengguna yang optimal melalui fitur-fitur yang lengkap dan intuitif.

## Rangkuman Database

### Entitas dan Atribut

#### Users
- `id` (Primary Key)
- `name`
- `email` (unique)
- `password`
- `roles` (USER, MERCHANT, COURIER)
- `username`
- `phone_number`
- `created_at`
- `updated_at`

#### Merchants
- `id` (Primary Key)
- `name`
- `owner_id` (Foreign Key ke Users)
- `address`
- `phone_number`
- `created_at`
- `updated_at`

#### Products
- `id` (Primary Key)
- `merchant_id` (Foreign Key ke Merchants)
- `category_id` (Foreign Key ke Product_Categories)
- `name`
- `description`
- `price`
- `created_at`
- `updated_at`

#### Product_Categories
- `id` (Primary Key)
- `name`
- `softDeletes`
- `created_at`
- `updated_at`

#### Product_Galleries
- `id` (Primary Key)
- `products_id` (Foreign Key ke Products)
- `url`
- `softDeletes`
- `created_at`
- `updated_at`

#### Orders
- `id` (Primary Key)
- `user_id` (Foreign Key ke Users)
- `total_amount`
- `order_status` (PENDING, PROCESSING, COMPLETED, CANCELED)
- `created_at`
- `updated_at`

#### Order_Items
- `id` (Primary Key)
- `order_id` (Foreign Key ke Orders)
- `product_id` (Foreign Key ke Products)
- `merchant_id` (Foreign Key ke Merchants)
- `quantity`
- `price`
- `created_at`
- `updated_at`

#### Loyalty_Points
- `id` (Primary Key)
- `user_id` (Foreign Key ke Users)
- `points`
- `created_at`

#### Couriers
- `id` (Primary Key)
- `user_id` (Foreign Key ke Users)
- `vehicle_type`
- `license_plate`
- `created_at`
- `updated_at`

#### Transactions
- `id` (Primary Key)
- `order_id` (Foreign Key ke Orders)
- `user_id` (Foreign Key ke Users)
- `user_location_id` (Foreign Key ke User_Locations)
- `total_price`
- `shipping_price`
- `payment_date`
- `status` (PENDING, COMPLETED, CANCELED)
- `payment_method` (MANUAL, ONLINE)
- `payment_status` (PENDING, COMPLETED, FAILED)
- `rating`
- `note`
- `created_at`
- `updated_at`

#### User_Locations
- `id` (Primary Key)
- `customer_name`
- `user_id` (Foreign Key ke Users)
- `address`
- `longitude`
- `latitude`
- `address_type`
- `phone_number`
- `created_at`
- `updated_at`

#### Delivery
- `id` (Primary Key)
- `transaction_id` (Foreign Key ke Transactions)
- `courier_id` (Foreign Key ke Couriers)
- `delivery_status` (PENDING, IN_PROGRESS, DELIVERED, CANCELED)
- `estimated_delivery_time`
- `actual_delivery_time`
- `created_at`
- `updated_at`

#### Product_Reviews
- `id` (Primary Key)
- `user_id` (Foreign Key ke Users)
- `product_id` (Foreign Key ke Products)
- `rating`
- `comment`
- `created_at`
- `updated_at`

#### Delivery_Items
- `id` (Primary Key)
- `delivery_id` (Foreign Key ke Deliveries)
- `order_item_id` (Foreign Key ke Order_Items)
- `pickup_status` (ENUM: 'PENDING', 'PICKED_UP')
- `pickup_time` (DATETIME, nullable)
- `created_at`
- `updated_at`

#### Courier_Batches
- `id` (Primary Key)
- `courier_id` (Foreign Key ke Couriers)
- `status` (ENUM: 'PREPARING', 'IN_PROGRESS', 'COMPLETED')
- `start_time` (DATETIME)
- `end_time` (DATETIME)
- `created_at`
- `updated_at`

### Relasi Antar Tabel
- **Users** memiliki banyak **Merchants**, **Orders**, **Loyalty_Points**, ****User _Locations**, **Product_Reviews**, dan **Transactions**.
- **Merchants** terkait dengan satu **User ** dan memiliki banyak **Products** serta **Order_Items**.
- **Products** terkait dengan satu **Merchant** dan satu **Product_Category**, serta memiliki banyak **Order_Items**, **Product_Galleries**, dan **Product_Reviews**.
- **Product_Categories** memiliki banyak **Products**.
- **Orders** terkait dengan satu **User ** dan memiliki banyak **Order_Items** serta satu **Transaction**.
- **Order_Items** terkait dengan satu **Order**, satu **Product**, dan satu **Merchant**, serta memiliki satu **Delivery_Item**.
- **Loyalty_Points** terkait dengan satu **User **.
- **Couriers** terkait dengan satu **User ** dan memiliki banyak **Deliveries** serta **Courier_Batches**.
- **Transactions** terkait dengan satu **Order**, satu **User **, dan satu **User _Location**, serta memiliki satu **Delivery**.
- **User _Locations** terkait dengan satu **User **.
- **Deliveries** terkait dengan satu **Transaction**, satu **Courier**, dan memiliki banyak **Delivery_Items**.
- **Product_Reviews** terkait dengan satu **User ** dan satu **Product**.
- **Delivery_Items** terkait dengan satu **Delivery** dan satu **Order_Item**.
- **Courier_Batches** terkait dengan satu **Courier** dan memiliki banyak **Deliveries**.

### Kesimpulan dan Fitur Utama
- **Multi-Merchant Support**: Sistem mendukung multi-merchant, memungkinkan satu pesanan mencakup produk dari berbagai merchant.
- **Manajemen Produk**: Produk terkait dengan kategori dan merchant, serta galeri produk memungkinkan penambahan gambar multiple untuk setiap produk.
- **Sistem Pemesanan**: Orders menyimpan informasi pesanan keseluruhan, sedangkan Order_Items menyimpan detail item dalam pesanan.
- **Transaksi dan Pembayaran**: Transactions menyimpan informasi pembayaran dan status, mendukung berbagai metode pembayaran (manual dan online).
- **Sistem Pengiriman**: Deliveries melacak status pengiriman untuk setiap transaksi, dengan Courier_Batches memungkinkan pengelompokan pengiriman untuk efisiensi.
- **Manajemen Pengguna**: Users dapat memiliki peran berbeda (USER, MERCHANT, COURIER), dengan User_Locations mendukung penyimpanan beberapa alamat untuk setiap pengguna.
- **Sistem Loyalitas**: Loyalty_Points memungkinkan implementasi sistem loyalitas pelanggan.
- **Ulasan Produk**: Product_Reviews memungkinkan pengguna memberikan ulasan dan rating untuk produk.
- **Manajemen Kurir**: Couriers terkait dengan Users, memungkinkan pengelolaan informasi kurir.
- **Fleksibilitas Lokasi**: User_Locations memungkinkan pengguna menyimpan beberapa alamat.
- **Pelacakan Pengiriman Detail**: Delivery_Items memungkinkan pelacakan status pickup untuk setiap item dalam pengiriman.

Struktur database ini memberikan fondasi yang kuat untuk aplikasi Antarkanma, mendukung berbagai fitur e-commerce dan manajemen pengiriman. Sistem ini memungkinkan skalabilitas dan fleksibilitas untuk pengembangan fitur lebih lanjut di masa depan.

## Spesifikasi Teknis
Untuk informasi lebih lanjut tentang spesifikasi teknis, API, dan integrasi pihak ketiga, silakan lihat bagian berikutnya dalam dokumentasi ini.

+------------------------+        +------------------------+
|         User           |        |        Merchant        |
+------------------------+        +------------------------+
| -id: int               |        | -id: int               |
| -name: string          |        | -name: string          |
| -email: string         |        | -ownerId: int          |
| -password: string      |        | -address: string       |
| -role: enum            |        | -phoneNumber: string   |
| -username: string      |        +------------------------+
| -phoneNumber: string   |        | +manageProfile()       |
+------------------------+        | +addProduct()          |
| +register()            |        | +editProduct()         |
| +login()               |        | +deleteProduct()       |
| +viewCatalog()         |        | +manageInventory()     |
| +searchProduct()       |        | +viewOrders()          |
| +addToCart()           |        | +processOrder()        |
| +manageCart()          |        | +managePromotions()    |
| +checkout()            |        | +setOperatingHours()   |
| +trackOrder()          |        | +viewAnalytics()       |
| +leaveReview()         |        +------------------------+
| +manageProfile()       |                 |
| +viewOrderHistory()    |                 |
| +manageAddress()       |                 |
| +useLoyaltyPoints()    |                 |
| +viewPromotions()      |                 |
| +saveFavoriteProduct() |                 |
| +cancelOrder()         |                 |
| +requestRefund()       |                 |
+------------------------+                 |
           |                               |
           |                               |
           v                               v
+------------------------+        +------------------------+
|        Product         |        |         Order          |
+------------------------+        +------------------------+
| -id: int               |        | -id: int               |
| -merchantId: int       |        | -userId: int           |
| -categoryId: int       |        | -totalAmount: decimal  |
| -name: string          |        | -status: enum          |
| -description: text     |        +------------------------+
| -price: decimal        |        | +create()              |
+------------------------+        | +update()              |
| +create()              |        | +cancel()              |
| +update()              |        +------------------------+
| +delete()              |                 |
+------------------------+                 |
           |                               |
           |                               |
           v                               v
+------------------------+        +------------------------+
|     ProductGallery     |        |       OrderItem        |
+------------------------+        +------------------------+
| -id: int               |        | -id: int               |
| -productId: int        |        | -orderId: int          |
| -url: string           |        | -productId: int        |
+------------------------+        | -merchantId: int       |
                                  | -quantity: int         |
+------------------------+        | -price: decimal        |
|    ProductCategory     |        +------------------------+
+------------------------+
| -id: int               |        +------------------------+
| -name: string          |        |      Transaction       |
+------------------------+        +------------------------+
                                  | -id: int               |
+------------------------+        | -orderId: int          |
|      LoyaltyPoint      |        | -userId: int           |
+------------------------+        | -userLocationId: int   |
| -id: int               |        | -totalPrice: decimal   |
| -userId: int           |        | -shippingPrice: decimal|
| -points: int           |        | -paymentDate: datetime |
+------------------------+        | -status: enum          |
                                  | -paymentMethod: enum   |
+------------------------+        | -paymentStatus: enum   |
|        Courier         |        | -rating: int           |
+------------------------+        | -note: string          |
| -id: int               |        +------------------------+
|

+------------------------+        +------------------------+
|        Courier         |        |      UserLocation      |
+------------------------+        +------------------------+
| -id: int               |        | -id: int               |
| -userId: int           |        | -userId: int           |
| -vehicleType: string   |        | -customerName: string  |
| -licensePlate: string  |        | -address: string       |
+------------------------+        | -longitude: float      |
| +login()               |        | -latitude: float       |
| +viewDeliveryTasks()   |        | -addressType: string   |
| +acceptDeliveryTask()  |        | -phoneNumber: string   |
| +updateDeliveryStatus()|        +------------------------+
| +completeDelivery()    |        | +create()              |
| +viewDeliveryHistory() |        | +update()              |
| +manageProfile()       |        | +delete()              |
| +viewEarnings()        |        +------------------------+
| +setAvailabilityStatus()|
| +viewDeliveryRoute()   |        +------------------------+
| +contactCustomer()     |        |        Delivery        |
| +reportIssue()         |        +------------------------+
+------------------------+        | -id: int               |
           |                      | -transactionId: int    |
           |                      | -courierId: int        |
           v                      | -status: enum          |
+------------------------+        | -estimatedDeliveryTime:|
|    CourierBatch        |        |  datetime              |
+------------------------+        | -actualDeliveryTime:   |
| -id: int               |        |  datetime              |
| -courierId: int        |        +------------------------+
| -status: enum          |        | +create()              |
| -startTime: datetime   |        | +updateStatus()        |
| -endTime: datetime     |        +------------------------+
+------------------------+                 |
| +create()              |                 |
| +updateStatus()        |                 |
+------------------------+                 |
                                           v
+------------------------+        +------------------------+
|     ProductReview      |        |     DeliveryItem       |
+------------------------+        +------------------------+
| -id: int               |        | -id: int               |
| -userId: int           |        | -deliveryId: int       |
| -productId: int        |        | -orderItemId: int      |
| -rating: int           |        | -pickupStatus: enum    |
| -comment: text         |        | -pickupTime: datetime  |
+------------------------+        +------------------------+
| +create()              |        | +create()              |
| +update()              |        | +updatePickupStatus()  |
+------------------------+        +------------------------+

+------------------------+
|        Admin           |
+------------------------+
| -id: int               |
| -name: string          |
| -email: string         |
| -password: string      |
+------------------------+
| +login()               |
| +manageUsers()         |
| +manageMerchants()     |
| +manageCouriers()      |
| +manageCategories()    |
| +viewTransactionReports()|
| +managePaymentSystem() |
| +manageAppPolicies()   |
| +handleUserComplaints()|
| +managePromotions()    |
| +viewAnalytics()       |
| +manageAppContent()    |
| +setCommissionRates()  |
| +manageThirdPartyIntegrations()|
| +verifyMerchantsAndCouriers()|
| +manageLoyaltySystem() |
| +manageNotifications() |
+------------------------+


Relasi antar kelas:
User memiliki banyak Order, UserLocation, dan LoyaltyPoint.
Merchant memiliki banyak Product.
Product terkait dengan satu ProductCategory dan memiliki banyak ProductGallery.Order memiliki banyak OrderItem.
Transaction terkait dengan satu Order dan satu UserLocation.
Delivery terkait dengan satu Transaction dan satu Courier.
CourierBatch memiliki banyak Delivery.
ProductReview terkait dengan satu User dan satu Product.
DeliveryItem terkait dengan satu Delivery dan satu OrderItem.
Catatan tambahan:

Kelas User memiliki atribut 'role' yang bisa berupa USER, MERCHANT, atau COURIER. Ini memungkinkan satu tabel user untuk menangani berbagai jenis pengguna.
Kelas Merchant, Courier, dan Admin sebenarnya bisa dianggap sebagai ekstensi dari User dengan role yang sesuai. Namun, untuk kejelasan dan pemisahan concern, mereka dibuat sebagai kelas terpisah.
Kelas Transaction menghubungkan Order dengan proses pembayaran dan pengiriman.
CourierBatch memungkinkan pengelompokan beberapa Delivery untuk efisiensi pengiriman.
DeliveryItem memungkinkan pelacakan status pickup untuk setiap item dalam satu pengiriman.
Fungsionalitas utama:

User dapat melakukan berbagai aktivitas seperti melihat katalog, mengelola keranjang, checkout, melacak pesanan, dan memberikan ulasan.
Merchant dapat mengelola produk, melihat dan memproses pesanan, serta mengelola promosi dan jam operasional toko.
Courier dapat menerima dan mengelola tugas pengiriman, memperbarui status pengiriman, dan melaporkan masalah.
Admin memiliki akses luas untuk mengelola seluruh aspek sistem, termasuk pengguna, merchant, kurir, kategori produk, promosi, dan kebijakan aplikasi.
Aspek keamanan dan otorisasi:

Meskipun tidak ditampilkan secara eksplisit, setiap metode dalam kelas-kelas ini harus memiliki mekanisme otorisasi untuk memastikan bahwa hanya pengguna dengan hak akses yang sesuai yang dapat menjalankan fungsi tertentu.
Skalabilitas dan perluasan:

Struktur kelas ini memungkinkan untuk penambahan fitur baru di masa depan. Misalnya, bisa ditambahkan kelas untuk menangani program afiliasi, sistem voucher, atau integrasi dengan layanan pihak ketiga.
Penanganan pembayaran:

Kelas Transaction mencakup informasi pembayaran, tetapi untuk implementasi yang lebih kompleks, mungkin diperlukan kelas terpisah untuk menangani berbagai metode pembayaran dan gateway pembayaran.
Analitik dan pelaporan:

Meskipun tidak ditampilkan secara eksplisit, data dari berbagai kelas ini dapat digunakan untuk menghasilkan laporan dan analitik yang berguna untuk Admin, Merchant, dan mungkin juga untuk Courier.
Notifikasi dan komunikasi:

Sistem ini akan memerlukan mekanisme notifikasi yang kuat untuk memberi tahu pengguna tentang status pesanan, promosi baru, tugas pengiriman, dll. Ini bisa diimplementasikan sebagai kelas atau layanan terpisah.
Berikut adalah deskripsi tekstual dari DFD Level 0 untuk Antarkanma:


Verify

Open In Editor
Edit
Copy code
[User] <---> (Registrasi, Login, Data Profil)
       <---> (Pencarian Produk, Katalog)
       <---> (Pesanan, Pembayaran)
       <---> (Ulasan, Poin Loyalitas)
       <---> (Alamat Pengiriman)
             |
             |
             v
+----------------------------+
|                            |
|                            |
|        Sistem              |
|        Antarkanma          |
|                            |
|                            |
+----------------------------+
             ^
             |
             |
[Merchant] <---> (Registrasi, Login, Data Profil)
           <---> (Manajemen Produk)
           <---> (Pesanan Masuk, Proses Pesanan)
           <---> (Laporan Penjualan, Analitik)
             |
             |
             v
[Kurir] <---> (Login, Data Profil)
        <---> (Tugas Pengiriman)
        <---> (Update Status Pengiriman)
        <---> (Laporan Pengiriman)
             |
             |
             v
[Admin] <---> (Login, Manajemen Pengguna)
        <---> (Manajemen Sistem)
        <---> (Laporan dan Analitik)
        <---> (Konfigurasi Aplikasi)
Penjelasan:

User:

Mengirim data registrasi dan login
Menerima informasi profil
Mengirim permintaan pencarian dan menerima katalog produk
Mengirim pesanan dan data pembayaran
Menerima konfirmasi pesanan dan status pengiriman
Mengirim ulasan dan menerima informasi poin loyalitas
Mengirim dan menerima data alamat pengiriman
Merchant:

Mengirim data registrasi dan login
Menerima informasi profil
Mengirim dan menerima data produk
Menerima pesanan masuk dan mengirim status proses pesanan
Menerima laporan penjualan dan data analitik
Kurir:

Mengirim data login
Menerima informasi profil
Menerima tugas pengiriman
Mengirim update status pengiriman
Mengirim laporan pengiriman
Admin:

Mengirim data login
Mengelola data pengguna (User, Merchant, Kurir)
Mengelola konfigurasi sistem
Menerima laporan dan data analitik platform
Mengirim konfigurasi aplikasi
Sistem Antarkanma:

Menerima dan memproses semua input dari entitas eksternal
Menyimpan dan mengelola data
Menghasilkan output yang sesuai untuk setiap entitas
# DFD Level 1 Sistem Antarkanma

[Pengguna] <---> [1.0 Manajemen Akun dan Autentikasi] <---> [D1 Pengguna]

[Pengguna] ---> [2.0 Pencarian dan Katalog Produk] <---> [D2 Produk]
[Penjual] ---> [2.0 Pencarian dan Katalog Produk]

[Pengguna] ---> [3.0 Pemesanan dan Pembayaran] <---> [D3 Pesanan]
[3.0 Pemesanan dan Pembayaran] <---> [D4 Pembayaran]

[Penjual] <---> [4.0 Manajemen Produk dan Inventori] <---> [D2 Produk]
[4.0 Manajemen Produk dan Inventori] <---> [D5 Inventori]

[Penjual] ---> [5.0 Proses Pengiriman] <---> [D6 Pengiriman]
[Kurir] <---> [5.0 Proses Pengiriman]

[Pengguna] ---> [6.0 Ulasan dan Penilaian] <---> [D7 Ulasan]
[Penjual] <--- [6.0 Ulasan dan Penilaian]
[Kurir] <--- [6.0 Ulasan dan Penilaian]

[Penjual] ---> [7.0 Manajemen Promosi] <---> [D8 Promosi]

[Pengguna] <---> [8.0 Dukungan Pelanggan] <---> [D9 Tiket Dukungan]

[Admin] ---> [9.0 Analisis dan Pelaporan] <--- [D3 Pesanan]
[9.0 Analisis dan Pelaporan] <--- [D4 Pembayaran]
[9.0 Analisis dan Pelaporan] <--- [D6 Pengiriman]
[9.0 Analisis dan Pelaporan] ---> [Penjual]
[9.0 Analisis dan Pelaporan] ---> [Kurir]

[Sistem] ---> [10.0 Notifikasi] ---> [Pengguna]
[10.0 Notifikasi] ---> [Penjual]
[10.0 Notifikasi] ---> [Kurir]
Penjelasan singkat:

Manajemen Akun dan Autentikasi: Menangani registrasi, login, dan manajemen profil pengguna.
Pencarian dan Katalog Produk: Memungkinkan pengguna mencari dan melihat produk, serta penjual mengelola katalog.
Pemesanan dan Pembayaran: Mengelola proses pemesanan dan pembayaran oleh pengguna.
Manajemen Produk dan Inventori: Penjual dapat mengelola produk dan stok mereka.
Proses Pengiriman: Menangani alur pengiriman dari penjual ke kurir hingga ke pengguna.
Ulasan dan Penilaian: Pengguna dapat memberikan ulasan dan penilaian untuk produk dan layanan.
Manajemen Promosi: Penjual dapat membuat dan mengelola promosi.
Dukungan Pelanggan: Menangani tiket dukungan dan pertanyaan pengguna.
Analisis dan Pelaporan: Menghasilkan laporan dan analisis untuk berbagai keperluan.
Notifikasi: Mengirim pemberitahuan ke berbagai pihak terkait aktivitas dalam sistem, seperti konfirmasi pesanan, status pengiriman, dan promosi baru.

[Pengguna] ke [1.0 Manajemen Akun dan Autentikasi]: Pengguna mengirimkan data registrasi, login, dan pembaruan profil.

[1.0 Manajemen Akun dan Autentikasi] ke [D1 Pengguna]: Sistem menyimpan dan memperbarui data pengguna di database.

[Pengguna] ke [2.0 Pencarian dan Katalog Produk]: Pengguna mengirimkan permintaan pencarian atau filter produk.

[2.0 Pencarian dan Katalog Produk] ke [D2 Produk]: Sistem mengambil data produk dari database untuk ditampilkan kepada pengguna.

[Pengguna] ke [3.0 Pemesanan dan Pembayaran]: Pengguna mengirimkan data pesanan dan informasi pembayaran.

[3.0 Pemesanan dan Pembayaran] ke [D3 Pesanan] dan [D4 Pembayaran]: Sistem menyimpan data pesanan dan pembayaran ke database masing-masing.

[Penjual] ke [4.0 Manajemen Produk dan Inventori]: Penjual mengirimkan data produk baru atau pembaruan stok.

[4.0 Manajemen Produk dan Inventori] ke [D2 Produk] dan [D5 Inventori]: Sistem memperbarui data produk dan inventori di database.

[Penjual] dan [Kurir] ke [5.0 Proses Pengiriman]: Penjual dan kurir memperbarui status pengiriman.

[5.0 Proses Pengiriman] ke [D6 Pengiriman]: Sistem menyimpan dan memperbarui data pengiriman di database.

[Pengguna] ke [6.0 Ulasan dan Penilaian]: Pengguna mengirimkan ulasan dan penilaian untuk produk atau layanan.

[6.0 Ulasan dan Penilaian] ke [D7 Ulasan]: Sistem menyimpan ulasan dan penilaian ke database.

[Penjual] ke [7.0 Manajemen Promosi]: Penjual membuat dan mengelola promosi.

[7.0 Manajemen Promosi] ke [D8 Promosi]: Sistem menyimpan data promosi ke database.

[Pengguna] ke [8.0 Dukungan Pelanggan]: Pengguna mengirimkan pertanyaan atau keluhan.

[8.0 Dukungan Pelanggan] ke [D9 Tiket Dukungan]: Sistem menyimpan tiket dukungan ke database.

[Admin] ke [9.0 Analisis dan Pelaporan]: Admin meminta laporan atau analisis tertentu.

[9.0 Analisis dan Pelaporan] mengambil data dari berbagai database untuk menghasilkan laporan.

[Sistem] ke [10.0 Notifikasi]: Berbagai proses dalam sistem memicu notifikasi.

[10.0 Notifikasi] ke [Pengguna], [Penjual], dan [Kurir]: Sistem mengirimkan notifikasi ke pihak-pihak terkait.
DFD Level 1 ini memberikan gambaran umum tentang proses-proses utama dalam sistem Antarkanma dan bagaimana data mengalir di antara proses-proses tersebut serta entitas eksternal. Ini membantu dalam memahami fungsi-fungsi utama sistem dan interaksinya dengan pengguna serta penyimpanan data.

Beberapa poin penting yang dapat diambil dari DFD Level 1 ini:

Sistem terpusat: Semua proses utama terhubung dan saling berinteraksi, menunjukkan sistem yang terintegrasi.

Pemisahan tugas: Ada pembagian yang jelas antara fungsi-fungsi untuk pengguna, penjual, kurir, dan admin.

Manajemen data: Penggunaan berbagai database menunjukkan pengelolaan data yang terstruktur untuk berbagai aspek sistem.

Alur informasi: DFD menggambarkan bagaimana informasi mengalir dari satu proses ke proses lainnya dan antara proses dengan penyimpanan data.

Interaksi pengguna: Diagram menunjukkan berbagai titik interaksi pengguna dengan sistem, dari pencarian produk hingga pemberian ulasan.

Proses bisnis: DFD mencerminkan proses bisnis utama dalam e-commerce, seperti pemesanan, pembayaran, dan pengiriman.

Analisis dan pelaporan: Adanya proses khusus untuk analisis menunjukkan fokus pada pengambilan keputusan berbasis data.

Komunikasi: Sistem notifikasi menunjukkan pentingnya komunikasi real-time dengan semua pihak yang terlibat.

Untuk pengembangan lebih lanjut, mungkin diperlukan DFD Level 2 atau 3 untuk beberapa proses yang lebih kompleks, seperti proses pemesanan dan pembayaran atau manajemen pengiriman. Ini akan memberikan detail lebih lanjut tentang sub-proses dan aliran data yang lebih spesifik dalam setiap area fungsional.

Selain itu, DFD ini bisa menjadi dasar untuk pengembangan arsitektur sistem, desain database, dan spesifikasi kebutuhan perangkat lunak. Ini juga dapat membantu dalam mengidentifikasi potensi bottleneck atau area yang memerlukan perhatian khusus dalam hal keamanan atau kinerja
[Users]
id (PK)
name
email (unique)
password
roles (ENUM: USER, MERCHANT, COURIER)
username
phone_number
created_at
updated_at
  |
  |--1----* [Merchants]
  |         id (PK)
  |         owner_id (FK -> Users)
  |         name
  |         address
  |         phone_number
  |         created_at
  |         updated_at
  |
  |--1----* [Orders]
  |         id (PK)
  |         user_id (FK -> Users)
  |         total_amount
  |         order_status (ENUM: PENDING, PROCESSING, COMPLETED, CANCELED)
  |         created_at
  |         updated_at
  |
  |--1----* [Loyalty_Points]
  |         id (PK)
  |         user_id (FK -> Users)
  |         points
  |         created_at
  |
  |--1----1 [Couriers]
  |         id (PK)
  |         user_id (FK -> Users)
  |         vehicle_type
  |         license_plate
  |         created_at
  |         updated_at
  |
  |--1----* [User_Locations]
  |         id (PK)
  |         user_id (FK -> Users)
  |         customer_name
  |         address
  |         longitude
  |         latitude
  |         address_type
  |         phone_number
  |         created_at
  |         updated_at
  |
  |--1----* [Product_Reviews]
  |         id (PK)
  |         user_id (FK -> Users)
  |         product_id (FK -> Products)
  |         rating
  |         comment
  |         created_at
  |         updated_at
  |
  |--1----* [Transactions]
            id (PK)
            order_id (FK -> Orders)
            user_id (FK -> Users)
            user_location_id (FK -> User_Locations)
            total_price
            shipping_price
            payment_date
            status (ENUM: PENDING, COMPLETED, CANCELED)
            payment_method (ENUM: MANUAL, ONLINE)
            payment_status (ENUM: PENDING, COMPLETED, FAILED)
            rating
            note
            created_at
            updated_at

[Merchants]
  |
  |--1----* [Products]
            id (PK)
            merchant_id (FK -> Merchants)
            category_id (FK -> Product_Categories)
            name
            description
            price
            created_at
            updated_at
              |
              |--1----* [Product_Galleries]
                        id (PK)
                        products_id (FK -> Products)
                        url
                        softDeletes
                        created_at
                        updated_at

[Product_Categories]
id (PK)
name
softDeletes
created_at
updated_at
  |
  |--1----* [Products]

[Orders]
  |
  |--1----* [Order_Items]
            id (PK)
            order_id (FK -> Orders)
            product_id (FK -> Products)
            merchant_id (FK -> Merchants)
            quantity
            price
            created_at
            updated_at

[Transactions]
  |
  |--1----1 [Delivery]
            id (PK)
            transaction_id (FK -> Transactions)
            courier_id (FK -> Couriers)
            delivery_status (ENUM: PENDING, IN_PROGRESS, DELIVERED, CANCELED)
            estimated_delivery_time
            actual_delivery_time
            created_at
            updated_at
              |
              |--1----* [Delivery_Items]
                        id (PK)
                        delivery_id (FK -> Deliveries)
                        order_item_id (FK -> Order_Items)
                        pickup_status (ENUM: PENDING, PICKED_UP)
                        pickup_time (DATETIME, nullable)
                        created_at
                        updated_at

[Courier_Batches]
id (PK)
courier_id (FK -> Couriers)
status (ENUM: PREPARING, IN_PROGRESS, COMPLETED)
start_time (DATETIME)
end_time (DATETIME)
created_at
updated_at
  |
  |--1----* [Delivery]

[Order_Items]
id (PK)
order_id (FK -> Orders)
product_id (FK -> Products)
merchant_id (FK -> Merchants)
quantity
price
created_at
updated_at
  |
  |--1----1 [Delivery_Items]

[Product_Reviews]
id (PK)
user_id (FK -> Users)
product_id (FK -> Products)
rating
comment
created_at
updated_at

[Products]
  |
  |--1----* [Product_Reviews]

[Users]
  |
  |--1----* [Product_Reviews]




   Penjelasan ini akan mencakup setiap entitas, atributnya, dan hubungan antar entitasnya.

Users

Entitas utama yang menyimpan informasi semua pengguna sistem.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap pengguna.
name: Nama lengkap pengguna.
email (unique): Alamat email pengguna, harus unik.
password: Password terenkripsi untuk keamanan akun.
roles (ENUM: USER, MERCHANT, COURIER): Peran pengguna dalam sistem.
username: Nama pengguna untuk login.
phone_number: Nomor telepon pengguna.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
One-to-Many dengan Merchants: Satu user dapat memiliki banyak merchant.
One-to-Many dengan Orders: Satu user dapat membuat banyak pesanan.
One-to-Many dengan Loyalty_Points: Satu user dapat memiliki banyak entri poin loyalitas.
One-to-One dengan Couriers: Satu user dapat menjadi satu kurir.
One-to-Many dengan User_Locations: Satu user dapat memiliki banyak alamat.
One-to-Many dengan Product_Reviews: Satu user dapat memberikan banyak ulasan produk.
One-to-Many dengan Transactions: Satu user dapat memiliki banyak transaksi.
Merchants

Menyimpan informasi tentang penjual atau toko dalam sistem.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap merchant.
owner_id (Foreign Key ke Users): Menghubungkan merchant dengan pemiliknya.
name: Nama merchant atau toko.
address: Alamat fisik merchant.
phone_number: Nomor telepon merchant.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Users: Banyak merchant dapat dimiliki oleh satu user.
One-to-Many dengan Products: Satu merchant dapat memiliki banyak produk.
One-to-Many dengan Order_Items: Satu merchant dapat memiliki banyak item pesanan.
Products

Menyimpan informasi tentang produk yang dijual dalam sistem.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap produk.
merchant_id (Foreign Key ke Merchants): Menghubungkan produk dengan merchantnya.
category_id (Foreign Key ke Product_Categories): Menghubungkan produk dengan kategorinya.
name: Nama produk.
description: Deskripsi produk.
price: Harga produk.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Merchants: Banyak produk dapat dimiliki oleh satu merchant.
Many-to-One dengan Product_Categories: Banyak produk dapat termasuk dalam satu kategori.
One-to-Many dengan Order_Items: Satu produk dapat muncul di banyak item pesanan.
One-to-Many dengan Product_Galleries: Satu produk dapat memiliki banyak gambar.
One-to-Many dengan Product_Reviews: Satu produk dapat memiliki banyak ulasan.
Product_Categories

Menyimpan kategori-kategori produk.
Atribut:
id (Primary Key): Identifikasi


Product_Categories (lanjutan)

Atribut:
id (Primary Key): Identifikasi unik untuk setiap kategori.
name: Nama kategori.
description: Deskripsi kategori (opsional).
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
One-to-Many dengan Products: Satu kategori dapat memiliki banyak produk.
Orders

Menyimpan informasi tentang pesanan yang dibuat oleh pengguna.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap pesanan.
user_id (Foreign Key ke Users): Menghubungkan pesanan dengan pembelinya.
status (ENUM: PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED): Status pesanan.
total_price: Total harga pesanan.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Users: Banyak pesanan dapat dibuat oleh satu pengguna.
One-to-Many dengan Order_Items: Satu pesanan dapat memiliki banyak item pesanan.
One-to-One dengan Deliveries: Satu pesanan terhubung dengan satu pengiriman.
One-to-One dengan Transactions: Satu pesanan terhubung dengan satu transaksi.
Order_Items

Menyimpan detail item dalam setiap pesanan.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap item pesanan.
order_id (Foreign Key ke Orders): Menghubungkan item dengan pesanannya.
product_id (Foreign Key ke Products): Menghubungkan item dengan produknya.
merchant_id (Foreign Key ke Merchants): Menghubungkan item dengan merchantnya.
quantity: Jumlah item yang dipesan.
price: Harga satuan item saat dipesan.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Orders: Banyak item dapat ada dalam satu pesanan.
Many-to-One dengan Products: Banyak item pesanan dapat merujuk pada satu produk.
Many-to-One dengan Merchants: Banyak item pesanan dapat berasal dari satu merchant.
One-to-One dengan Delivery_Items: Satu item pesanan terhubung dengan satu item pengiriman.
Deliveries

Menyimpan informasi tentang pengiriman pesanan.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap pengiriman.
order_id (Foreign Key ke Orders): Menghubungkan pengiriman dengan pesanannya.
courier_id (Foreign Key ke Couriers): Menghubungkan pengiriman dengan kurirnya.
status (ENUM: PENDING, IN_PROGRESS, DELIVERED): Status pengiriman.
estimated_arrival: Perkiraan waktu tiba.
actual_arrival: Waktu tiba sebenarnya.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
One-to-One dengan Orders: Satu pengiriman terhubung dengan satu pesanan.
Many-to-One dengan Couriers: Banyak pengiriman dapat ditangani oleh satu kurir.
One-to-Many dengan Delivery_Items: Satu pengiriman dapat memiliki banyak item pengiriman.
Many-to-One dengan Courier_Batches: Banyak pengiriman dapat dikelompokkan dalam satu batch kurir.
Delivery_Items

Menyimpan detail item dalam setiap pengiriman.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap item pengiriman.
delivery_id (Foreign Key ke Deliveries): Menghubungkan item dengan pengirimannya.
order_item_id (Foreign Key ke Order_Items): Menghubungkan item pengiriman dengan item pesanan.
pickup_status (ENUM: PENDING, PICKED_UP): Status pengambilan item.
pickup_time (DATETIME, nullable): Waktu pengambilan item.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Deliveries: Banyak item pengiriman dapat ada dalam satu pengiriman.
One-to-One dengan Order_Items: Satu item pengiriman terhubung dengan satu item pesanan.
Couriers

Menyimpan informasi tentang kurir yang menangani pengiriman.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap kurir.
user_id (Foreign Key ke Users): Menghubungkan kurir dengan akun penggunanya.
vehicle_type: Jenis kendaraan yang digunakan kurir.
license_plate: Nomor plat kendaraan kurir.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
One-to-One dengan Users: Satu kurir terhubung dengan satu akun pengguna.
One-to-Many dengan Deliveries: Satu kurir dapat menangani banyak pengiriman.
One-to-Many dengan Courier_Batches: Satu kurir dapat memiliki banyak batch pengiriman.
Courier_Batches

Menyimpan informasi tentang batch pengiriman yang ditangani oleh kurir.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap batch.
courier_id (Foreign Key ke Couriers): Menghubungkan batch dengan kurirnya.
status (ENUM: PREPARING, IN_PROGRESS, COMPLETED): Status batch pengiriman.
start_time (DATETIME): Waktu mulai batch pengiriman.
end_time (DATETIME): Waktu selesai batch pengiriman.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Couriers: Banyak batch dapat ditangani oleh satu kurir.
One-to-Many dengan Deliveries: Satu batch dapat mencakup banyak pengiriman.
Transactions

Menyimpan informasi tentang transaksi keuangan dalam sistem.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap transaksi.
user_id (Foreign Key ke Users): Menghubungkan transaksi dengan penggunanya.
order_id (Foreign Key ke Orders): Menghubungkan transaksi dengan pesanannya.
amount: Jumlah transaksi.
status (ENUM: PENDING, COMPLETED, FAILED): Status transaksi.
payment_method: Metode pembayaran yang digunakan.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi (lanjutan):
Many-to-One dengan Users: Banyak transaksi dapat dilakukan oleh satu pengguna.
One-to-One dengan Orders: Satu transaksi terhubung dengan satu pesanan.
Loyalty_Points

Menyimpan informasi tentang poin loyalitas pengguna.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap entri poin loyalitas.
user_id (Foreign Key ke Users): Menghubungkan poin dengan penggunanya.
points: Jumlah poin yang diperoleh atau digunakan.
transaction_type (ENUM: EARNED, REDEEMED): Jenis transaksi poin.
description: Deskripsi transaksi poin.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Users: Banyak entri poin loyalitas dapat dimiliki oleh satu pengguna.
User_Locations

Menyimpan informasi tentang alamat pengguna.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap lokasi.
user_id (Foreign Key ke Users): Menghubungkan lokasi dengan penggunanya.
address_type (ENUM: HOME, OFFICE, OTHER): Jenis alamat.
address: Alamat lengkap.
latitude: Koordinat latitude.
longitude: Koordinat longitude.
is_default (BOOLEAN): Menandai apakah ini alamat default.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Users: Banyak lokasi dapat dimiliki oleh satu pengguna.
Product_Galleries

Menyimpan gambar-gambar produk.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap gambar.
product_id (Foreign Key ke Products): Menghubungkan gambar dengan produknya.
image_url: URL gambar produk.
is_primary (BOOLEAN): Menandai apakah ini gambar utama produk.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Products: Banyak gambar dapat dimiliki oleh satu produk.
Product_Reviews

Menyimpan ulasan produk dari pengguna.
Atribut:
id (Primary Key): Identifikasi unik untuk setiap ulasan.
user_id (Foreign Key ke Users): Menghubungkan ulasan dengan penggunanya.
product_id (Foreign Key ke Products): Menghubungkan ulasan dengan produknya.
rating (INTEGER): Peringkat produk (misalnya 1-5).
comment: Komentar ulasan.
created_at dan updated_at: Timestamp untuk penciptaan dan pembaruan record.
Relasi:
Many-to-One dengan Users: Banyak ulasan dapat diberikan oleh satu pengguna.
Many-to-One dengan Products: Banyak ulasan dapat diberikan untuk satu produk.User                    Sistem Antarkanma           Merchant                Kurir
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
 |   19. Update Status Pengiriman                       |                     |
 |<-----------------------------|                       |                     |
 |                              |                       |                     |
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
 |                              |                       |                     |

 Penjelasan langkah-langkah:

1-5: User mencari dan memilih produk, lalu menambahkannya ke keranjang. 
6-10: User melakukan checkout, memasukkan data pengiriman, dan mengonfirmasi pesanan. 11-13: Sistem mengirim pesanan ke Merchant dan mengonfirmasi ke User.
14-16: Merchant memproses pesanan dan memperbarui statusnya di sistem. 
17-18: Sistem menugaskan Kurir untuk pengiriman, dan Kurir menerima tugas tersebut. 19: Sistem memperbarui status pengiriman kepada User. 
20: User menerima pesanan dan mengonfirmasi penerimaan di sistem. 
21-22: Sistem memperbarui status pesanan ke Merchant dan menandai tugas Kurir sebagai selesai. 
23-24: Sistem meminta User untuk memberikan review, dan User mengirimkan reviewnya.
Penjelasan tambahan:

Interaksi Pengguna:

Diagram ini menunjukkan bagaimana User berinteraksi dengan sistem mulai dari pencarian produk hingga pemberian review.
Setiap langkah melibatkan pertukaran informasi antara User dan sistem.
Proses di Belakang Layar:

Setelah User mengonfirmasi pesanan, ada serangkaian proses yang terjadi di belakang layar melibatkan Merchant dan Kurir.
Sistem bertindak sebagai perantara, mengoordinasikan komunikasi antara semua pihak.
Status Updates:

Sepanjang proses, sistem terus memperbarui status pesanan dan menginformasikannya kepada User.
Ini mencakup konfirmasi pesanan, status pemrosesan oleh Merchant, dan status pengiriman oleh Kurir.
Peran Merchant:

Merchant menerima pesanan, memprosesnya, dan memperbarui statusnya di sistem.
Ini menunjukkan integrasi yang erat antara sistem Antarkanma dan operasi Merchant.
Penugasan dan Peran Kurir:

Sistem menugaskan Kurir secara otomatis setelah Merchant memproses pesanan.
Kurir berinteraksi dengan sistem untuk menerima tugas dan memperbarui status pengiriman.
Konfirmasi dan Review:

Setelah pesanan diterima, User diminta untuk mengonfirmasi penerimaan.
Sistem kemudian meminta User untuk memberikan review, yang penting untuk umpan balik dan peningkatan layanan.
Alur Informasi:

Diagram ini menunjukkan bagaimana informasi mengalir antara berbagai aktor dalam sistem.
Sistem Antarkanma bertindak sebagai hub pusat, mengelola dan mendistribusikan informasi ke semua pihak yang terlibat.
Otomatisasi:

Banyak langkah dalam proses ini bisa diotomatisasi, seperti penugasan kurir dan permintaan review.
Ini membantu meningkatkan efisiensi dan konsistensi layanan.
Transparansi:

Sequence diagram ini menunjukkan tingkat transparansi yang tinggi dalam proses, di mana User dapat melacak status pesanan mereka di setiap tahap.
Skalabilitas:

Meskipun diagram ini menunjukkan proses dasar, struktur ini memungkinkan untuk penambahan langkah-langkah tambahan atau fitur baru di masa depan.
Berikut adalah versi yang diperbarui:


Verify

Open In Editor
Edit
Copy code
[User]
  - Mendaftar
  - Login
  - Melihat katalog produk
  - Mencari produk
  - Menambahkan produk ke keranjang
  - Mengelola keranjang belanja
  - Melakukan checkout
  - Memilih metode pembayaran
  - Melakukan pembayaran
  - Melacak pesanan
  - Memberikan ulasan produk
  - Mengelola profil
  - Melihat riwayat pesanan
  - Menghubungi layanan pelanggan
  - Mengelola alamat pengiriman
  - Menggunakan dan melihat poin loyalitas
  - Melihat dan menggunakan promo
  - Menyimpan produk favorit
  - Membatalkan pesanan
  - Meminta pengembalian dana

[Merchant]
  - Login
  - Mengelola profil toko
  - Menambahkan produk baru
  - Mengedit produk
  - Menghapus produk
  - Mengelola stok produk
  - Melihat pesanan masuk
  - Memproses pesanan
  - Menandai pesanan siap diambil
  - Melihat laporan penjualan
  - Mengelola promosi
  - Mengatur jam operasional toko
  - Mengelola kategori produk toko
  - Melihat ulasan dan rating toko
  - Merespon ulasan pelanggan
  - Mengatur metode pembayaran yang diterima
  - Melihat analitik toko

[Kurir]
  - Login
  - Melihat tugas pengiriman
  - Menerima tugas pengiriman
  - Mengambil pesanan dari merchant
  - Memperbarui status pengiriman
  - Menyelesaikan pengiriman
  - Melihat riwayat pengiriman
  - Mengelola profil
  - Melihat pendapatan
  - Mengatur status ketersediaan
  - Melihat rute pengiriman
  - Menghubungi pelanggan atau merchant
  - Melaporkan masalah pengiriman

[Admin]
  - Login
  - Mengelola pengguna
  - Mengelola merchant
  - Mengelola kurir
  - Mengelola kategori produk
  - Melihat laporan transaksi
  - Mengelola sistem pembayaran
  - Mengelola kebijakan aplikasi
  - Menangani keluhan pengguna
  - Mengelola promosi platform
  - Melihat analitik platform
  - Mengelola konten aplikasi
  - Mengatur komisi dan biaya layanan
  - Mengelola integrasi pihak ketiga
  - Melakukan verifikasi merchant dan kurir
  - Mengelola sistem poin loyalitas
  - Mengelola notifikasi sistem
Penjelasan tambahan untuk fitur-fitur baru:

User:

Mengelola alamat pengiriman: Menambah, mengedit, atau menghapus alamat.
Menggunakan dan melihat poin loyalitas: Melihat saldo poin dan menggunakannya untuk diskon.
Melihat dan menggunakan promo: Melihat promo yang tersedia dan menggunakannya saat checkout.
Menyimpan produk favorit: Menandai produk sebagai favorit untuk akses cepat.
Membatalkan pesanan: Opsi untuk membatalkan pesanan sebelum diproses.
Meminta pengembalian dana: Mengajukan refund untuk pesanan yang bermasalah.

Merchant:

Mengatur jam operasional toko: Menentukan waktu buka dan tutup toko.
Mengelola kategori produk toko: Membuat dan mengatur kategori khusus untuk produk di toko mereka.
Melihat ulasan dan rating toko: Melihat feedback dari pelanggan.
Merespon ulasan pelanggan: Memberikan tanggapan terhadap ulasan pelanggan.
Mengatur metode pembayaran yang diterima: Memilih metode pembayaran yang ingin diterima di toko.
Melihat analitik toko: Melihat statistik penjualan, produk terlaris, dll.
Kurir:

Melihat pendapatan: Melihat rincian pendapatan dari pengiriman yang telah dilakukan.
Mengatur status ketersediaan: Menandai diri sebagai tersedia atau tidak untuk menerima tugas.
Melihat rute pengiriman: Melihat peta dan rute optimal untuk pengiriman.
Menghubungi pelanggan atau merchant: Fitur komunikasi dalam aplikasi.
Melaporkan masalah pengiriman: Melaporkan kendala atau masalah selama proses pengiriman.
Admin:

Mengelola promosi platform: Membuat dan mengelola promosi untuk seluruh platform.
Melihat analitik platform: Melihat statistik keseluruhan platform, termasuk transaksi, pengguna aktif, dll.
Mengelola konten aplikasi: Mengatur konten seperti banner, pengumuman, dll.
Mengatur komisi dan biaya layanan: Menentukan persentase komisi untuk merchant dan biaya layanan.
Mengelola integrasi pihak ketiga: Mengatur integrasi dengan layanan pihak ketiga seperti penyedia pembayaran, peta, dll.
Melakukan verifikasi merchant dan kurir: Proses verifikasi untuk merchant dan kurir baru.
Mengelola sistem poin loyalitas: Mengatur aturan perolehan dan penukaran poin loyalitas.
Mengelola notifikasi sistem: Mengatur notifikasi push, email, atau SMS untuk pengguna.