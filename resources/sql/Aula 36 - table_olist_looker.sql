-- ============================================================
--    Domínio:   Modelo analítico de pedidos (Olist) para Looker/BI
--    Fatos:     roxschool_olist_ecommerce.olist_order_items         (order_id, order_item_id, product_id, seller_id, price, freight_value)
--               roxschool_olist_ecommerce.olist_orders              (order_id, customer_id, order_status, *_timestamp)
--    Dimensão:  roxschool_olist_ecommerce.olist_products            (product_id, product_category_name, ...)
--    Dimensão:  roxschool_olist_ecommerce.olist_sellers             (seller_id, seller_city, seller_state, ...)
--    Dimensão:  roxschool_olist_ecommerce.olist_customers           (customer_id, customer_zip_code_prefix, customer_city, customer_state, ...)
--    Dimensão:  roxschool_olist_ecommerce.olist_geolocation         (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, ...)
--    Pagto:     roxschool_olist_ecommerce.olist_order_payments      (order_id, payment_type, payment_installments, payment_value)
--    Observações:
--      - CTE payments agrega por pedido para evitar multiplicação de linhas (SUM, COUNT, MAX, ANY_VALUE).
--      - CTE orders_norm normaliza datas (DATE) para filtros e painéis (Looker).
--      - JOIN em geolocation é através de ZIP prefix (pode haver múltiplos por prefixo).
-- ============================================================


-- ============================================================
-- CTE 1) Pagamentos agregados por pedido (evita multiplicar linhas)
--    - order_payment_total: soma dos pagamentos do pedido
--    - payment_count: quantidade de registros de pagamento
--    - any_payment_type: amostra de um tipo de pagamento (não determinístico)
--    - max_installments: maior parcelamento
-- ============================================================
WITH payments AS (
  SELECT
    order_id,
    SUM(payment_value)      AS order_payment_total,
    COUNT(*)                AS payment_count,
    ANY_VALUE(payment_type) AS any_payment_type,
    MAX(payment_installments) AS max_installments
  FROM `roxschool_olist_ecommerce.olist_order_payments`
  GROUP BY order_id
),

-- ============================================================
-- CTE 2) Campos de data/duração prontos (facilita filtros no Looker)
--    - Converte timestamps para DATE para uso em filtros e partições lógicas.
-- ============================================================
orders_norm AS (
  SELECT
    order_id,
    customer_id,
    order_status,
    DATE(order_purchase_timestamp)              AS order_date,
    CAST(order_purchase_timestamp AS DATE)      AS purchase_date,
    CAST(order_approved_at AS DATE)             AS approved_date,
    CAST(order_delivered_customer_date AS DATE) AS delivered_date,
    CAST(order_estimated_delivery_date AS DATE) AS estimated_delivery_date
  FROM `roxschool_olist_ecommerce.olist_orders`
)

-- ============================================================
-- Seleção final: chaves, datas/status, métricas de item (GMV), dimensões e pagamentos
--    - price_band: faixas de preço por item
--    - delivery_days: diferença (dias) entre compra e entrega
-- ============================================================
SELECT
  -- Chaves
  o.order_id,
  oi.order_item_id,
  oi.product_id,
  oi.seller_id,
  o.customer_id,

  -- Datas / status
  o.order_status,
  o.order_date,
  o.purchase_date,
  o.approved_date,
  o.delivered_date,
  o.estimated_delivery_date,

  -- Métricas item (GMV por item, frete, etc.)
  oi.price                      AS item_price,    --preço do item
  oi.freight_value              AS item_freight,  --frete do item
  (oi.price + oi.freight_value) AS item_gmv,      --GMV do item

  -- Dimensão de produto
  p.product_category_name       AS product_category,

  -- Dimensão de cliente
  c.customer_city,
  c.customer_state,
  gc.geolocation_lat,
  gc.geolocation_lng,

  -- Dimensão de vendedor
  s.seller_city,
  s.seller_state,

  -- Pagamentos agregados por pedido
  pay.order_payment_total,
  pay.payment_count,
  pay.any_payment_type,
  pay.max_installments,

  -- Derivações simples para análises no Looker (sem janelas)
  CASE
    WHEN oi.price <  50  THEN 'A) < R$50'
    WHEN oi.price < 100  THEN 'B) R$50-100'
    WHEN oi.price < 200  THEN 'C) R$100-200'
    WHEN oi.price < 500  THEN 'D) R$200-500'
    ELSE                      'E) >= R$500'
  END AS price_band,  --faixa de preço

  CASE
    WHEN o.delivered_date IS NOT NULL
      THEN DATE_DIFF(o.delivered_date, o.purchase_date, DAY)
    ELSE NULL
  END AS delivery_days

-- ============================================================
-- Origens e relacionamentos
--    - USING (coluna) equivale a ON f.col = d.col e elimina duplicidade de nome.
-- ============================================================
FROM `roxschool_olist_ecommerce.olist_order_items`   AS oi
JOIN orders_norm                                     AS o   USING (order_id)
JOIN `roxschool_olist_ecommerce.olist_products`      AS p   USING (product_id)
JOIN `roxschool_olist_ecommerce.olist_sellers`       AS s   USING (seller_id)
JOIN `roxschool_olist_ecommerce.olist_customers`     AS c   ON c.customer_id = o.customer_id
LEFT JOIN payments                                   AS pay USING (order_id)
LEFT JOIN `roxschool_olist_ecommerce.olist_geolocation` AS gc
  ON gc.geolocation_zip_code_prefix = c.customer_zip_code_prefix

-- (Sem WHERE/GROUP BY/ORDER BY para manter dataset base; ajuste conforme a análise)
;


-- ============================================================
-- Dicas de performance/custo específicas deste modelo:
--    - Evite multiplicação de linhas por pagamentos: agregue (CTE payments) antes de juntar.
--    - ANY_VALUE(payment_type) é não-determinístico; para consistência, escolha regra explícita
--      (ex.: o mais frequente por pedido via janela ou FIRST_VALUE por data).
--    - geolocation por ZIP prefix pode ter várias linhas por prefixo; se necessário, dedupe
--      (ex.: escolher a coordenada mais frequente por prefixo) para evitar fan-out.
--    - Filtros por datas (order_date/purchase_date) reduzem bytes lidos; empurre WHERE na camada de consumo.
--    - Projete só colunas necessárias ao dashboard; SELECT enxuto poupa custo e acelera o BI.
--    - Para joins quentes, considere tabelas/visões materializadas ou clustering nas chaves de junção.
-- ============================================================
