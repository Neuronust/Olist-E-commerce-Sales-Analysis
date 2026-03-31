CREATE TABLE "customers" (
  "customer_id" varchar PRIMARY KEY,
  "customer_unique_id" varchar,
  "customer_zip_code_prefix" integer,
  "customer_city" varchar,
  "customer_state" varchararchar
);

CREATE TABLE "geolocation" (
  "geolocation_zip_code_prefix" varchar,
  "geolocation_lat" numeric,
  "geolocation_lng" numeric,
  "geolocation_city" varchar,
  "geolocation_state" varchar
);

CREATE TABLE "orders" (
  "order_id" varchar PRIMARY KEY,
  "customer_id" varchar,
  "order_status" varchar,
  "order_purchase_timestamp" timestamp,
  "order_approved_at" timestamp,
  "order_delivered_carrier_date" timestamp,
  "order_delivered_customer_date" timestamp,
  "order_estimated_delivery_date" timestamp
);

CREATE TABLE "order_items" (
  "order_id" varchar,
  "order_item_id" integer,
  "product_id" varchar,
  "seller_id" varchar,
  "shipping_limit_date" timestamp,
  "price" numeric,
  "freight_value" numeric
);

CREATE TABLE "order_payments" (
  "order_id" varchar,
  "payment_sequential" integer,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" numeric
);

CREATE TABLE "order_reviews" (
  "review_id" varchar PRIMARY KEY,
  "order_id" varchar,
  "review_score" integer,
  "review_comment_title" varchar,
  "review_comment_message" varchar,
  "review_creation_date" timestamp,
  "reviw_answer_timestamp" timestamp
);

CREATE TABLE "products" (
  "product_id" varchar PRIMARY KEY,
  "product_category_name" varchar,
  "product_name_lenght" integer,
  "product_description_lenght" integer,
  "product_photos_qty" integer,
  "product_weight_g" integer,
  "product_length_cm" integer,
  "product_height_cm" integer,
  "product_width_cm" integer
);

CREATE TABLE "sellers" (
  "seller_id" varchar PRIMARY KEY,
  "seller_zip_code_prefix" integer,
  "seller_city" varchar,
  "seller_state" varchar
);

CREATE TABLE "product_category_name_translation" (
  "product_category_name" varchar,
  "product_category_name_english" varchar
);

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("seller_id") REFERENCES "sellers" ("seller_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_reviews" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;
