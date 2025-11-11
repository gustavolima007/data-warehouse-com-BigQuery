-- ============================================================
--    Domínio:   Provisionamento Olist no BigQuery (Tabelas EXTERNAS CSV em GCS)
--    Objetivo:  Criar dataset (schema) e mapear arquivos do bucket GCS como tabelas externas.
--    Parâmetros:
--      - project_id: projeto GCP alvo
--      - dataset_id: dataset para as tabelas
--      - bucket:     nome do bucket (sem gs://)
--      - prefix:     prefixo/pasta-base onde os CSVs estão
--      - location:   região do dataset (ex.: US, US-EAST1)
--    Observações:
--      - As tabelas externas leem os dados diretamente do GCS (sem mover/ingestar).
--      - Inferência de schema automática (exceto onde definido explicitamente).
-- ============================================================

-- ============================================================
-- Bloco de variáveis (ajuste ao seu ambiente)
-- ============================================================
DECLARE project_id STRING DEFAULT 'bigquery-iniciante-roxschool';
DECLARE dataset_id STRING DEFAULT 'roxschool_olist_ecommerce';
DECLARE bucket     STRING DEFAULT 'roxschool_olist_dataset';
DECLARE prefix     STRING DEFAULT 'olist_database';
DECLARE location   STRING DEFAULT 'US';

-- ============================================================
-- Dataset (SCHEMA) com location explícita
-- ============================================================
EXECUTE IMMEDIATE FORMAT(
  "CREATE SCHEMA IF NOT EXISTS `%s.%s` OPTIONS(location='%s')",
  project_id, dataset_id, location
);

-- ============================================================
-- olist_closed_deals_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_closed_deals`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_closed_deals_dataset/olist_closed_deals_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_customers_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_customers`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_customers_dataset/olist_customers_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_geolocation_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_geolocation`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_geolocation_dataset/olist_geolocation_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_marketing_qualified_leads_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_marketing_qualified_leads`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_marketing_qualified_leads_dataset/olist_marketing_qualified_leads_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_items_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_items`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_items_dataset/olist_order_items_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_payments_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_payments`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_payments_dataset/olist_order_payments_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_order_reviews_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_order_reviews`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_order_reviews_dataset/olist_order_reviews_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_orders_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_orders`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_orders_dataset/olist_orders_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_products_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_products`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_products_dataset/olist_products_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- olist_sellers_dataset → tabela externa
-- ============================================================
EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE EXTERNAL TABLE `%s.%s.olist_sellers`
  OPTIONS(
    format = 'CSV',
    skip_leading_rows = 1,
    field_delimiter = ',',
    quote = '"',
    uris = ['gs://%s/%s/olist_sellers_dataset/olist_sellers_dataset.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);

-- ============================================================
-- product_category_name_translation → tabela externa (schema explícito)
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
    uris = ['gs://%s/%s/product_category_name_translation/product_category_name_translation.csv']
  )""",
  project_id, dataset_id, bucket, prefix
);


-- ============================================================
-- Dicas de operação/custo (tabelas externas CSV no BigQuery):
--    - Schema: se preciso de tipos exatos ou colunas obrigatórias, defina o schema explicitamente (como no translation).
--    - Particionamento: tabelas externas NÃO são particionadas; empurre filtros de data em consultas para reduzir bytes lidos.
--    - Performance: CSV é mais pesado; quando estabilizar o layout, considere materializar em tabelas nativas (Parquet/ORC → melhor).
--    - Segurança: use URIs restritas via IAM do GCS; evite “*” no path sem necessidade.
--    - Governança: padronize nomes e documente origem/atualização dos arquivos no comentário do objeto (OPTIONS(description)).
--    - Portabilidade: mantenha variáveis (project/dataset/bucket/prefix) para facilitar réplica entre ambientes.
-- ============================================================
