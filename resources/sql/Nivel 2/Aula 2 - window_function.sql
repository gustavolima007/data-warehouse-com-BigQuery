-- ============================================================
-- ROX SCHOOL CARS | BigQuery SQL
-- Tema: WINDOW FUNCTIONS
--
-- Dataset: roxschool_cars
-- Convenção de métrica:
--   gross = sale_price * quantity
--   net   = (sale_price - discount_value) * quantity
-- ============================================================
-- ============================================================
-- AULA 1 | WINDOW FUNCTION vs GROUP BY
-- ============================================================

-- 1) GROUP BY: faturamento (net) por loja
SELECT
  store_name,
  state,
  city,
  SUM((sale_price - discount_value) * quantity) AS net_revenue
FROM roxschool_cars.vw_sales_enriched
GROUP BY store_name, state, city
ORDER BY net_revenue DESC;

-- 2) WINDOW FUNCTION: faturamento (net) da loja SEM perder o detalhe da venda
SELECT
  sale_id,
  sale_date,
  store_name,
  state,
  city,
  (sale_price - discount_value) * quantity AS net_amount,
  SUM((sale_price - discount_value) * quantity) OVER (
    PARTITION BY store_name
  ) AS net_revenue_store
FROM roxschool_cars.vw_sales_enriched
ORDER BY store_name, sale_date, sale_id;

-- ============================================================
-- AULA 2 | VALUE WINDOW FUNCTIONS (LAG/LEAD/FIRST_VALUE/LAST_VALUE)
-- ============================================================

-- 3) LAG: comparar uma venda com a venda anterior do MESMO VENDEDOR
SELECT
  seller_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,
  LAG((sale_price - discount_value) * quantity) OVER (
    PARTITION BY seller_name
    ORDER BY sale_date, sale_id
  ) AS prev_net_amount,
  (sale_price - discount_value) * quantity
  - LAG((sale_price - discount_value) * quantity) OVER (
      PARTITION BY seller_name
      ORDER BY sale_date, sale_id
    ) AS diff_vs_prev
FROM roxschool_cars.vw_sales_enriched
ORDER BY seller_name, sale_date, sale_id;

-- 4) LEAD: olhar a próxima venda do MESMO CLIENTE (aqui não temos cliente)
SELECT
  store_name,
  seller_name,
  sale_date,
  sale_id,
  LEAD(sale_date) OVER (
    PARTITION BY store_name, seller_name
    ORDER BY sale_date, sale_id
  ) AS next_sale_date,
  DATE_DIFF(
    LEAD(sale_date) OVER (
      PARTITION BY store_name, seller_name
      ORDER BY sale_date, sale_id
    ),
    sale_date,
    DAY
  ) AS days_to_next_sale
FROM roxschool_cars.vw_sales_enriched
ORDER BY store_name, seller_name, sale_date, sale_id;

-- 5) FIRST_VALUE / LAST_VALUE: primeira e última venda do vendedor (net_amount)
SELECT
  seller_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,

  FIRST_VALUE((sale_price - discount_value) * quantity) OVER (
    PARTITION BY seller_name
    ORDER BY sale_date, sale_id
  ) AS first_sale_net_amount,

  LAST_VALUE((sale_price - discount_value) * quantity) OVER (
    PARTITION BY seller_name
    ORDER BY sale_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_sale_net_amount
FROM roxschool_cars.vw_sales_enriched
ORDER BY seller_name, sale_date, sale_id;

-- ============================================================
-- AULA 3 | RANKING WINDOW FUNCTIONS (ROW_NUMBER/RANK/DENSE_RANK)
-- ============================================================
-- 6) Ranking: Top vendedores por receita líquida (net)
SELECT
  seller_name,
  SUM((sale_price - discount_value) * quantity) AS net_revenue,
  RANK() OVER (ORDER BY SUM((sale_price - discount_value) * quantity) DESC) AS rank_revenue,
  DENSE_RANK() OVER (ORDER BY SUM((sale_price - discount_value) * quantity) DESC) AS dense_rank_revenue,
  ROW_NUMBER() OVER (ORDER BY SUM((sale_price - discount_value) * quantity) DESC) AS row_number_revenue
FROM roxschool_cars.vw_sales_enriched
GROUP BY seller_name
ORDER BY net_revenue DESC;

-- 7) Ranking por loja: top vendedores dentro de cada loja
SELECT
  store_name,
  seller_name,
  SUM((sale_price - discount_value) * quantity) AS net_revenue,
  DENSE_RANK() OVER (
    PARTITION BY store_name
    ORDER BY SUM((sale_price - discount_value) * quantity) DESC
  ) AS rank_in_store
FROM roxschool_cars.vw_sales_enriched
GROUP BY store_name, seller_name
ORDER BY store_name, rank_in_store, net_revenue DESC;

-- 8) Ranking de modelos mais vendidos por estado (por volume de receita ou quantidade)
SELECT
  state,
  make,
  model,
  SUM((sale_price - discount_value) * quantity) AS net_revenue,
  RANK() OVER (
    PARTITION BY state
    ORDER BY SUM((sale_price - discount_value) * quantity) DESC
  ) AS rank_model_in_state
FROM roxschool_cars.vw_sales_enriched
GROUP BY state, make, model
ORDER BY state, rank_model_in_state;

-- ============================================================
-- AULA 4 | AGGREGATE WINDOW FUNCTIONS (SUM/AVG/COUNT/MIN/MAX)
-- ============================================================

-- 9) Running total: receita líquida acumulada por loja ao longo do tempo
SELECT
  store_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,
  SUM((sale_price - discount_value) * quantity) OVER (
    PARTITION BY store_name
    ORDER BY sale_date, sale_id
  ) AS net_revenue_running
FROM roxschool_cars.vw_sales_enriched
ORDER BY store_name, sale_date, sale_id;

-- 10) Média móvel (rolling) de 7 vendas por loja (janela por linhas)
SELECT
  store_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,
  AVG((sale_price - discount_value) * quantity) OVER (
    PARTITION BY store_name
    ORDER BY sale_date, sale_id
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS moving_avg_last_7_sales
FROM roxschool_cars.vw_sales_enriched
ORDER BY store_name, sale_date, sale_id;

-- 11) Participação da venda no total do mês da loja (%)
SELECT
  store_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,
  DATE_TRUNC(sale_date, MONTH) AS month_ref,

  SUM((sale_price - discount_value) * quantity) OVER (
    PARTITION BY store_name, DATE_TRUNC(sale_date, MONTH)
  ) AS net_revenue_store_month,

  SAFE_DIVIDE(
    (sale_price - discount_value) * quantity,
    SUM((sale_price - discount_value) * quantity) OVER (
      PARTITION BY store_name, DATE_TRUNC(sale_date, MONTH)
    )
  ) AS pct_sale_in_store_month
FROM roxschool_cars.vw_sales_enriched
ORDER BY store_name, month_ref, sale_date, sale_id;

-- 12) Métricas completas do vendedor na mesma linha da venda
SELECT
  seller_name,
  sale_date,
  sale_id,
  (sale_price - discount_value) * quantity AS net_amount,

  COUNT(*) OVER (PARTITION BY seller_name) AS total_sales_by_seller,
  SUM((sale_price - discount_value) * quantity) OVER (PARTITION BY seller_name) AS total_net_by_seller,
  AVG((sale_price - discount_value) * quantity) OVER (PARTITION BY seller_name) AS avg_ticket_by_seller,
  MIN((sale_price - discount_value) * quantity) OVER (PARTITION BY seller_name) AS min_ticket_by_seller,
  MAX((sale_price - discount_value) * quantity) OVER (PARTITION BY seller_name) AS max_ticket_by_seller
FROM roxschool_cars.vw_sales_enriched
ORDER BY seller_name, sale_date, sale_id;

-- ============================================================
-- EXTRA | QUALIFY + Window (filtro pós-cálculo)
-- ============================================================

-- 13) “Top 3 vendedores por loja” usando QUALIFY
SELECT
  store_name,
  seller_name,
  SUM((sale_price - discount_value) * quantity) AS net_revenue,
  DENSE_RANK() OVER (
    PARTITION BY store_name
    ORDER BY SUM((sale_price - discount_value) * quantity) DESC
  ) AS rank_in_store
FROM roxschool_cars.vw_sales_enriched
GROUP BY store_name, seller_name
QUALIFY rank_in_store <= 3
ORDER BY store_name, rank_in_store, net_revenue DESC;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
