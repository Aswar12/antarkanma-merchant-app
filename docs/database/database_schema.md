# Database Schema

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
