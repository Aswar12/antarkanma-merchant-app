Mari saya jelaskan detail flow yang sudah diimplementasi:

Struktur Data:
Transaction (1)
  - courier_id (1 kurir untuk 1 transaksi)
  - courier_approval (PENDING/APPROVED/REJECTED)
  - timeout_at (5 menit dari pembuatan)
  - status (PENDING/COMPLETED/CANCELED)
  - payment_method (MANUAL/ONLINE)
  - payment_status (PENDING/COMPLETED/FAILED)
  └── Orders (many, per merchant)
      - merchant_id
      - merchant_approval (PENDING/APPROVED/REJECTED)
      - order_status (PENDING/PROCESSING/READY/COMPLETED/CANCELED)
      └── OrderItems (many, untuk merchant tersebut)
Flow Status:
A. Transaction Flow:
   PENDING (baru dibuat)
   ├── Mencari Kurir (timeout 5 menit)
   │   ├── Kurir Approve -> Lanjut ke Merchant Approval
   │   └── Timeout/No Kurir -> CANCELED
   ├── Merchant Approval
   │   ├── Semua Merchant Reject -> CANCELED
   │   └── Min 1 Merchant Approve -> COMPLETED (setelah delivery)
   └── Payment (parallel dengan approval)
       ├── ONLINE: Harus COMPLETED sebelum proses
       └── MANUAL: COMPLETED setelah delivery

B. Order Flow (per merchant):
   PENDING (baru dibuat)
   ├── Menunggu Kurir Approve Transaction
   ├── WAITING_APPROVAL (kurir sudah approve)
   │   ├── Merchant Approve -> PROCESSING
   │   └── Merchant Reject -> CANCELED
   ├── PROCESSING (merchant siapkan pesanan)
   ├── READY (siap diambil kurir)
   ├── PICKED_UP (kurir ambil pesanan)
   └── COMPLETED (sudah diantar)
Approval Flow:
A. Courier Approval:
   - Kurir lihat: list merchant, rute, items, total
   - Approve: update courier_id & status
   - Reject/Timeout: transaction canceled

B. Merchant Approval (setelah kurir approve):
   - Merchant lihat: items mereka, kurir yang assign
   - Approve: mulai proses pesanan
   - Reject: order merchant tersebut canceled
   - Order lain tetap jalan jika min 1 approve
Delivery Flow:
1. Kurir tunggu semua merchant approved siap
2. Ambil dari merchant sesuai rute
3. Antar ke customer
4. Update status:
   - Order: COMPLETED
   - Transaction: COMPLETED
   - Payment (if COD): COMPLETED

Ya benar, mari saya perjelas flow lengkapnya:

User membuat transaksi COD:
Transaction (PENDING, payment_method: MANUAL)
├── Order A (PENDING)
└── Order B (PENDING)
Sistem mencari kurir (timeout 5 menit):
Jika kurir approve:
Transaction (PENDING, courier_approval: APPROVED)
├── Order A (WAITING_APPROVAL)
└── Order B (WAITING_APPROVAL)
Jika timeout: semua CANCELED
Merchant approval (parallel):
Transaction (PENDING)
├── Order A: 
│   Merchant A approve -> PROCESSING -> READY
└── Order B:
    Merchant B reject -> CANCELED (Order B saja)
Proses tetap lanjut karena minimal 1 merchant approve:
Transaction (PENDING)
├── Order A (READY) -> PICKED_UP -> COMPLETED
└── Order B (CANCELED)
Setelah Order A completed:
Transaction (COMPLETED)
├── Order A (COMPLETED)
└── Order B (CANCELED)
Apakah flow ini sudah sesuai? Jika ya, saya akan buat migration untuk menambah status yang diperlukan.


yah tapi bagaimana flow status kurir ketika menjemput


blackbox has a question:
Mari saya perjelas flow kurir saat pengambilan dan pengantaran:

Kurir approve transaksi:
Transaction (PENDING, courier_approval: APPROVED)
├── Order A (WAITING_APPROVAL)
└── Order B (WAITING_APPROVAL)
Setelah merchant approve dan siap:
Transaction (PENDING)
├── Order A (READY) - Siap diambil di Merchant A
└── Order B (READY) - Siap diambil di Merchant B
Kurir mengambil pesanan:
Transaction (PENDING)
├── Order A: 
│   Kurir sampai -> klik PICKED_UP -> Merchant A konfirmasi
└── Order B:
    Kurir sampai -> klik PICKED_UP -> Merchant B konfirmasi
Kurir mengantar ke customer:
Transaction (PENDING)
├── Order A (PICKED_UP -> COMPLETED) - Setelah customer terima
└── Order B (PICKED_UP -> COMPLETED) - Setelah customer terima
Setelah semua order selesai:
Transaction (COMPLETED, payment_status: COMPLETED untuk COD)
├── Order A (COMPLETED)
└── Order B (COMPLETED)
