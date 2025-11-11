-- ============================================================
--    Domínio:   Análises do Módulo 10 — Dados Olist (E-commerce)
--    Fonte:     roxschool_olist_ecommerce.*
--    Objetivo:  Consolidar consultas analíticas clássicas sobre:
--                 Produtos,  Regiões,  Vendedores e  Clientes.
--    Observações:
--      - Todas as consultas consideram apenas pedidos "delivered".
--      - Ideal para dashboards (Looker, Data Studio, Power BI) e análises exploratórias.
-- ============================================================


-- ============================================================
--  ANÁLISE DE PRODUTOS
--    - Métricas por produto individual.
--    - ANY_VALUE() garante nome da categoria sem agrupar novamente.
-- ============================================================
SELECT
  oi.product_id,
  ANY_VALUE(p.product_category_name) AS product_category,
  COUNT(*)                          AS items_sold,      --quantidade de itens vendidos
  SUM(oi.price)                     AS revenue,         --receita total
  SUM(oi.freight_value)             AS freight_total,   --soma do frete
  AVG(oi.price)                     AS avg_price        --preço médio do produto
FROM `roxschool_olist_ecommerce.olist_order_items` AS oi
JOIN `roxschool_olist_ecommerce.olist_products`     AS p USING (product_id)
JOIN `roxschool_olist_ecommerce.olist_orders`       AS o USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id;


-- ============================================================
--  VENDAS POR REGIÃO (DIÁRIO)
--    - Agrupa por data e estado do cliente (UF).
--    - APPROX_COUNT_DISTINCT otimiza contagem de pedidos únicos.
-- ============================================================
SELECT
  DATE(o.order_purchase_timestamp)  AS order_date,
  c.customer_state                  AS uf,
  APPROX_COUNT_DISTINCT(o.order_id) AS approx_orders,  --número aproximado de pedidos
  SUM(oi.price)                     AS revenue,        --receita total
  SUM(oi.freight_value)             AS freight_total   --soma do frete
FROM `roxschool_olist_ecommerce.olist_order_items` AS oi
JOIN `roxschool_olist_ecommerce.olist_orders`      AS o  USING (order_id)
JOIN `roxschool_olist_ecommerce.olist_customers`   AS c  ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY order_date, uf
ORDER BY order_date, uf;


-- ============================================================
--  PRODUTOS POR REGIÃO
--    - Combina categoria de produto e UF do cliente.
--    - Mostra receita e volume de vendas por estado.
-- ============================================================
SELECT
  c.customer_state        AS uf,
  p.product_category_name AS product_category,
  COUNT(*)                AS items_sold,  --quantidade de itens vendidos
  SUM(oi.price)           AS revenue      --receita total
FROM `roxschool_olist_ecommerce.olist_order_items` AS oi
JOIN `roxschool_olist_ecommerce.olist_orders`      AS o  USING (order_id)
JOIN `roxschool_olist_ecommerce.olist_customers`   AS c  ON c.customer_id = o.customer_id
JOIN `roxschool_olist_ecommerce.olist_products`    AS p  USING (product_id)
WHERE o.order_status = 'delivered'
GROUP BY uf, product_category
ORDER BY uf, revenue DESC;


-- ============================================================
--  DESEMPENHO DE VENDEDORES
--    - Métricas agregadas por vendedor.
--    - Inclui tempo médio de entrega (diferença entre compra e entrega).
-- ============================================================
SELECT
  oi.seller_id,
  ANY_VALUE(s.seller_city)  AS seller_city,
  ANY_VALUE(s.seller_state) AS seller_state,
  COUNT(*)                  AS items_sold,
  SUM(oi.price)             AS revenue,
  AVG(
    DATE_DIFF(
      CAST(o.order_delivered_customer_date AS DATE),
      CAST(o.order_purchase_timestamp      AS DATE),
      DAY)
  ) AS avg_delivery_days
FROM `roxschool_olist_ecommerce.olist_order_items` AS oi
JOIN `roxschool_olist_ecommerce.olist_orders`      AS o  USING (order_id)
JOIN `roxschool_olist_ecommerce.olist_sellers`     AS s  USING (seller_id)
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY revenue DESC;


-- ============================================================
--  PERFIL DE COMPRADORES
--    - Métricas por cliente (Customer Lifetime Value básico).
--    - lifetime_gmv: soma total dos gastos do cliente.
--    - first/last_purchase_date: janela temporal de relacionamento.
-- ============================================================
SELECT
  c.customer_id,
  ANY_VALUE(c.customer_city)  AS city,
  ANY_VALUE(c.customer_state) AS state,
  APPROX_COUNT_DISTINCT(o.order_id) AS approx_orders,      --quantidade aproximada de pedidos
  SUM(oi.price)                     AS lifetime_gmv,       --valor total gasto
  MIN(DATE(o.order_purchase_timestamp)) AS first_purchase_date, --primeira compra
  MAX(DATE(o.order_purchase_timestamp)) AS last_purchase_date   --última compra
FROM `roxschool_olist_ecommerce.olist_order_items` AS oi
JOIN `roxschool_olist_ecommerce.olist_orders`      AS o  USING (order_id)
JOIN `roxschool_olist_ecommerce.olist_customers`   AS c  ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id
ORDER BY lifetime_gmv DESC;


-- ============================================================
-- Dicas de performance/custo (consultas analíticas Olist):
--    - WHERE o.order_status = 'delivered' reduz fortemente volume de dados (pushdown eficiente).
--    - Sempre utilize DATE() em timestamps quando o objetivo for agregação diária (ajuda partições lógicas).
--    - APPROX_COUNT_DISTINCT substitui COUNT(DISTINCT) em grandes datasets para reduzir custo e tempo.
--    - Prefira JOINs via USING quando colunas têm o mesmo nome (torna código mais limpo e sem ambiguidade).
--    - Crie visões materializadas para tabelas intermediárias (ex.: order_items_joined) para reuso no BI.
--    - Projete apenas colunas necessárias; SELECT enxuto reduz bytes lidos e custo no BigQuery.
-- ============================================================
