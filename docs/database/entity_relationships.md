# Entity Relationships

## Relasi Antar Tabel

- **Users** memiliki banyak:

  - **Merchants** (one-to-many)
  - **Orders** (one-to-many)
  - **Loyalty_Points** (one-to-many)
  - **User_Locations** (one-to-many)
  - **Product_Reviews** (one-to-many)
  - **Transactions** (one-to-many)

- **Merchants**:

  - Terkait dengan satu **User** (many-to-one)
  - Memiliki banyak **Products** (one-to-many)
  - Memiliki banyak **Order_Items** (one-to-many)

- **Products**:

  - Terkait dengan satu **Merchant** (many-to-one)
  - Terkait dengan satu **Product_Category** (many-to-one)
  - Memiliki banyak:
    - **Order_Items** (one-to-many)
    - **Product_Galleries** (one-to-many)
    - **Product_Reviews** (one-to-many)

- **Product_Categories**:

  - Memiliki banyak **Products** (one-to-many)

- **Orders**:

  - Terkait dengan satu **User** (many-to-one)
  - Memiliki banyak **Order_Items** (one-to-many)
  - Memiliki satu **Transaction** (one-to-one)

- **Order_Items**:

  - Terkait dengan:
    - Satu **Order** (many-to-one)
    - Satu **Product** (many-to-one)
    - Satu **Merchant** (many-to-one)
  - Memiliki satu **Delivery_Item** (one-to-one)

- **Loyalty_Points**:

  - Terkait dengan satu **User** (many-to-one)

- **Couriers**:

  - Terkait dengan satu **User** (one-to-one)
  - Memiliki banyak:
    - **Deliveries** (one-to-many)
    - **Courier_Batches** (one-to-many)

- **Transactions**:

  - Terkait dengan:
    - Satu **Order** (one-to-one)
    - Satu **User** (many-to-one)
    - Satu **User_Location** (many-to-one)
  - Memiliki satu **Delivery** (one-to-one)

- **User_Locations**:

  - Terkait dengan satu **User** (many-to-one)

- **Deliveries**:

  - Terkait dengan:
    - Satu **Transaction** (one-to-one)
    - Satu **Courier** (many-to-one)
  - Memiliki banyak **Delivery_Items** (one-to-many)

- **Product_Reviews**:

  - Terkait dengan:
    - Satu **User** (many-to-one)
    - Satu **Product** (many-to-one)

- **Delivery_Items**:

  - Terkait dengan:
    - Satu **Delivery** (many-to-one)
    - Satu **Order_Item** (one-to-one)

- **Courier_Batches**:
  - Terkait dengan satu **Courier** (many-to-one)
  - Memiliki banyak **Deliveries** (one-to-many)

## Catatan Penting

1. Sistem menggunakan soft deletes untuk beberapa entitas (Product_Categories, Product_Galleries) untuk mempertahankan integritas data historis.
2. Timestamps (created_at, updated_at) digunakan di hampir semua tabel untuk audit trail.
3. Status menggunakan ENUM untuk membatasi nilai yang valid dan konsistensi data.
4. Foreign keys digunakan untuk menjaga referential integrity antar tabel.
