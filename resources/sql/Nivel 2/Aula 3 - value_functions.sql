-- ============================================================
-- ROX SCHOOL CARS | BigQuery SQL
-- Tema: WINDOW FUNCTIONS
--
-- Dataset: roxschool_cars
-- Métrica utilizada:
--   gross = sale_price
-- ============================================================

-- ============================================================
-- AULA 1 | VALUE WINDOW FUNCTIONS (LAG / LEAD)
-- ============================================================

-- 1) LAG e LEAD: comparar a venda atual com a anterior e a próxima
--    do MESMO VENDEDOR, mantendo o detalhe da venda
SELECT
  seller_id,
  sale_date,
  sale_price,

  LAG(sale_price) OVER (
    PARTITION BY seller_id
    ORDER BY sale_date
  ) AS previous_sale_price,

  LEAD(sale_price) OVER (
    PARTITION BY seller_id
    ORDER BY sale_date
  ) AS next_sale_price
FROM roxschool_cars.fact_sales
ORDER BY seller_id, sale_date;

-- ============================================================
-- AULA 2 | GROUP BY vs WINDOW FUNCTIONS
-- ============================================================

-- 2) GROUP BY: métricas agregadas por vendedor
--    Resultado: uma linha por vendedor
SELECT
  seller_id,
  COUNT(*) AS sales_count,
  SUM(sale_price) AS total_sales,
  AVG(sale_price) AS avg_sale,
  MIN(sale_price) AS min_sale,
  MAX(sale_price) AS max_sale
FROM roxschool_cars.fact_sales
GROUP BY seller_id
ORDER BY total_sales DESC;

-- 3) WINDOW FUNCTIONS: métricas do vendedor SEM perder o detalhe da venda
--    Resultado: métricas agregadas aparecem na mesma linha da venda
SELECT
  seller_id,
  sale_date,
  sale_price,

  COUNT(*) OVER (
    PARTITION BY seller_id
  ) AS sales_count_seller,

  SUM(sale_price) OVER (
    PARTITION BY seller_id
  ) AS total_sales_seller,

  AVG(sale_price) OVER (
    PARTITION BY seller_id
  ) AS avg_sale_seller,

  MIN(sale_price) OVER (
    PARTITION BY seller_id
  ) AS min_sale_seller,

  MAX(sale_price) OVER (
    PARTITION BY seller_id
  ) AS max_sale_seller
FROM roxschool_cars.fact_sales
ORDER BY seller_id, sale_date;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
