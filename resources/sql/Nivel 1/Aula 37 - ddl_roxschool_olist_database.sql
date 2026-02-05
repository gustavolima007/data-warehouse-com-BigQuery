-- Versão para o GCP - Gustavo Lima

-- ============================================================
-- Domínio:   Provisionamento Olist no BigQuery
-- Objetivo:  Criar dataset e mapear CSVs do GCS como TABELAS EXTERNAS
-- Bucket:    gs://bucket_gl/olist_database
-- ============================================================

-- ============================================================
-- Bloco de variáveis
-- ============================================================
DECLARE project_id STRING DEFAULT 'pythongl';
DECLARE dataset_id STRING DEFAULT 'roxschool_olist_ecommerce';
DECLARE bucket     STRING DEFAULT 'bucket_gl';
DECLARE prefix     STRING DEFAULT 'olist_database';
DECLARE location   STRING DEFAULT 'US';

-- ============================================================
-- Criação do dataset (schema) com location explícita
-- ============================================================
EXECUTE IMMEDIATE FORMAT(
  "CREATE SCHEMA IF NOT EXISTS `%s.%s` OPTIONS(location='%s')",
  project_id, dataset_id, location
);

-- ============================================================
-- olist_closed_deals_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_closed_deals`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_closed_deals_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_customers_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_customers`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_customers_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_geolocation_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_geolocation`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_geolocation_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_marketing_qualified_leads_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_marketing_qualified_leads`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_marketing_qualified_leads_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_items_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_items`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_items_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_payments_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_payments`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_payments_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_reviews_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_reviews`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_reviews_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_orders_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_orders`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_orders_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_products_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_products`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_products_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_sellers_dataset
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_sellers`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_sellers_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- product_category_name_translation (schema explícito)
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.product_category_name_translation` (
    product_category_name STRING,
    product_category_name_english STRING
  )
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/product_category_name_translation.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);
