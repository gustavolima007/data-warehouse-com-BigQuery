-- ============================================================
--    Fato:     bigquery-iniciante-roxschool.roxschool_cars.fact_sales         (sale_id, car_id, seller_id, sale_price, sale_date)
--    Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_car            (car_id, vin, make, model, year, color)
--    Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_seller         (seller_id, seller_name, store_id, hire_date)
--    Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_store          (store_id, store_name, city, state, ...)
-- ============================================================

-- ============================================================
-- GROUP BY básico: quantidade de vendas por MARCA (make)
--    - COUNT(*) conta linhas da fato no nível de agrupamento escolhido.
-- ============================================================
SELECT
  c.make,
  COUNT(*) AS qtd_vendas --contagem de linhas ( vendas neste caso )
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY c.make
ORDER BY qtd_vendas DESC;


-- ============================================================
-- Várias métricas por MARCA+MODELO
--    - SUM/AVG/MIN/MAX em valores numéricos (sale_price).
-- ============================================================
SELECT
  c.make,
  c.model,
  COUNT(*)          AS qtd_vendas,    --contagem
  SUM(f.sale_price) AS receita_total, --soma
  AVG(f.sale_price) AS preco_medio,   --média
  MIN(f.sale_price) AS menor_preco,   --minima
  MAX(f.sale_price) AS maior_preco    --maxima
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY c.make, c.model
ORDER BY receita_total DESC;


-- ============================================================
-- COUNT DISTINCT: diversidade de vendedores por MARCA
--    - COUNT(DISTINCT ...) conta distintos dentro do grupo.
-- ============================================================
SELECT
  c.make,
  COUNT(*)                          AS qtd_vendas,                --contagem
  COUNT(DISTINCT f.seller_id)       AS qtd_vendedores_distintos   --contagem distinta ( conta só distintos )
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY c.make
ORDER BY qtd_vendedores_distintos DESC;


-- ============================================================
-- Agrupar por período (ANO/MÊS) + MARCA
--    - EXTRACT(YEAR/MONTH) a partir do timestamp/data de venda.
-- ============================================================
SELECT
  EXTRACT(YEAR FROM f.sale_date) AS ano,
  EXTRACT(MONTH FROM f.sale_date) AS mes,
  c.make,
  COUNT(*)          AS qtd_vendas,
  SUM(f.sale_price) AS receita_total
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY ano, mes, c.make
ORDER BY ano DESC, mes DESC, receita_total DESC;


-- ============================================================
-- GROUP BY com coluna derivada (faixas de preço)
--    - Demonstra como agrupar por uma EXPRESSÃO (CASE).
--    - HAVING filtra após a agregação (ex.: grupos com >= 5 vendas).
-- ============================================================
WITH vendas AS (
  SELECT
    c.make,
    c.model,
    CASE
      WHEN f.sale_price <  50000 THEN 'A) < 50k'
      WHEN f.sale_price < 100000 THEN 'B) 50k–100k'
      ELSE                           'C) >= 100k'
    END AS faixa_preco
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
  JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
    ON c.car_id = f.car_id
)
SELECT
  make,
  model,
  faixa_preco,
  COUNT(*) AS qtd_vendas
FROM vendas
GROUP BY make, model, faixa_preco
HAVING COUNT(*) >= 100                          -- HAVING usa agregação (diferente do WHERE)
ORDER BY make, model, faixa_preco;


-- ============================================================
-- GROUP BY + HAVING com condição de receita mínima
--    - Filtra marcas-modelos com receita total superior a um limite.
-- ============================================================
SELECT
  c.make,
  c.model,
  SUM(f.sale_price) AS receita_total,
  COUNT(*)          AS qtd_vendas
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
WHERE f.sale_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'
GROUP BY c.make, c.model
HAVING SUM(f.sale_price) > 100000 AND COUNT(*) > 2          -- só grupos com receita > 100k
ORDER BY receita_total DESC;


-- ============================================================
-- Subtotais com ROLLUP (total por MARCA e total geral)
--    - GROUP BY ROLLUP(make, model) retorna linhas extras:
--      * (make, model)               -> detalhe
--      * (make, NULL)                -> subtotal da marca
--      * (NULL, NULL)                -> total geral
--    - COALESCE rotula as linhas de subtotal/total.
-- ============================================================
SELECT
  COALESCE(c.make,  'TOTAL_GERAL')            AS make_nivel,    --substitui null pela string TOTAL_GERAL
  COALESCE(c.model, 'TOTAL_DA_MARCA')         AS model_nivel,   --substitui null pela string TOTAL_DA_MARCA
  COUNT(*)          AS qtd_vendas,                              --contagem
  SUM(f.sale_price) AS receita_total                            --soma
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY ROLLUP(c.make, c.model)
ORDER BY make_nivel, model_nivel;


-- ============================================================
-- Dica de performance/custo (não é uma query nova):
--    - Sempre projete só as colunas necessárias (evite SELECT *).
--    - Use filtros de partição (ex.: WHERE DATE(sale_date) >= ...) antes do GROUP BY.
--    - Agrupe por colunas relevantes para a análise; expressões (CASE/EXTRACT) são permitidas,
--      mas podem impedir pushdown de clustering dependendo do layout da tabela. 
--      ( Pushdown é uma otimização interna da execução do bigquery que será abordada em outros treinamentos )
-- ============================================================
