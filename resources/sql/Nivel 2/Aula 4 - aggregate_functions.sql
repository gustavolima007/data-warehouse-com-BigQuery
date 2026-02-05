-- ============================================================
-- ROX SCHOOL CARS | BigQuery SQL
-- Tema: WINDOW FUNCTIONS (GROUP BY vs OVER + RANK + TOP N)
--
-- Dataset: roxschool_cars
-- Métrica utilizada:
--   gross = sale_price
-- ============================================================

-- ============================================================
-- AULA 1 | GROUP BY (AGREGAÇÃO CLÁSSICA)
-- ============================================================

-- 1) GROUP BY: total de vendas (gross) por vendedor
--    Resultado: uma linha por seller_id
SELECT
  seller_id,
  SUM(sale_price) AS total_sales
FROM roxschool_cars.fact_sales
GROUP BY seller_id
ORDER BY total_sales DESC;

-- ============================================================
-- AULA 2 | WINDOW FUNCTION (OVER) SEM PERDER O DETALHE
-- ============================================================

-- 2) WINDOW: total de vendas (gross) do vendedor mantendo o detalhe da venda
--    Resultado: total_sales aparece em todas as linhas do mesmo seller_id
SELECT
  seller_id,
  sale_date,
  sale_price,
  SUM(sale_price) OVER (
    PARTITION BY seller_id
  ) AS total_sales_seller
FROM roxschool_cars.fact_sales
ORDER BY seller_id, sale_date;

-- ============================================================
-- AULA 3 | RANK SOBRE MÉTRICA DE WINDOW (CUIDADO COM DUPLICAÇÃO)
-- ============================================================

-- 3) Exemplo didático: ranking usando total_sales calculado via window
--    Observação: esse padrão replica o rank em várias linhas (uma por venda),
--    pois o detalhe ainda existe. Útil para ensinar, mas não para "Top N final".
WITH sales_with_total AS (
  SELECT
    seller_id,
    sale_date,
    sale_price,
    SUM(sale_price) OVER (
      PARTITION BY seller_id
    ) AS total_sales_seller
  FROM roxschool_cars.fact_sales
)
SELECT
  seller_id,
  sale_date,
  sale_price,
  total_sales_seller,
  RANK() OVER (
    ORDER BY total_sales_seller DESC
  ) AS rank_seller
FROM sales_with_total
ORDER BY rank_seller, seller_id, sale_date;

-- ============================================================
-- AULA 4 | TOP N CORRETO (RANK APÓS GROUP BY)
-- ============================================================

-- 4) Top 3 vendedores por total de vendas (gross)
--    Padrão recomendado: agrega primeiro, ranqueia depois
WITH ranked_sales AS (
  SELECT
    seller_id,
    SUM(sale_price) AS total_sales,
    RANK() OVER (
      ORDER BY SUM(sale_price) DESC
    ) AS rank_seller
  FROM roxschool_cars.fact_sales
  GROUP BY seller_id
)
SELECT
  seller_id,
  total_sales,
  rank_seller
FROM ranked_sales
WHERE rank_seller <= 3
ORDER BY rank_seller, total_sales DESC;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
