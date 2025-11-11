-- ============================================================
--    Domínio:   Subconsultas no BigQuery (IN, EXISTS, WITH/CTE, INLINE)
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--    Dimensões: bigquery-iniciante-roxschool.roxschool_cars.dim_seller, dim_car
--    Objetivo:  Demonstrar padrões de SUBQUERIES para filtros, existência, CTEs e “tabela calendário”.
--    Observações:
--      - Use sempre filtros de data/partição para reduzir bytes lidos.
--      - Prefira projetar apenas colunas necessárias (evite SELECT *).
-- ============================================================


-- ============================================================
-- 1) SUBQUERY SIMPLES com IN
--    “Traga vendas cujos vendedores foram admitidos a partir de 2021”
--    - IN compara f.seller_id com o conjunto retornado pela subconsulta.
-- ============================================================
SELECT
  f.sale_id,         --id da venda
  f.seller_id,       --vendedor
  f.sale_price       --preço da venda
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
WHERE f.seller_id IN (
  SELECT s.seller_id
  FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  WHERE s.hire_date >= DATE '2021-01-01'   --admissão a partir de 2021
)
ORDER BY f.sale_price DESC
LIMIT 20;


-- ============================================================
-- 2) SUBQUERY CORRELACIONADA com EXISTS
--    “Liste CARROS que tenham pelo menos 1 venda acima de 100k”
--    - EXISTS retorna TRUE se a subconsulta correlacionada encontrar ao menos 1 linha.
--    - Evita deduplicações desnecessárias e geralmente é mais eficiente que IN para esse padrão.
-- ============================================================
SELECT
  c.car_id,
  c.make,
  c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS c
WHERE EXISTS (
  SELECT 1
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
  WHERE f.car_id = c.car_id
    AND f.sale_price > 100000     --condição de existência
)
ORDER BY c.make, c.model;


-- ============================================================
-- 3) CTE (WITH) + subquery escalar no HAVING
--    “Modelos cuja MÉDIA de preço > MÉDIA GLOBAL no período 2025”
--    - A CTE 'periodo' restringe a fato e pode permitir pruning da partição.
--    - A subconsulta escalar no HAVING calcula a média global do período.
-- ============================================================
WITH periodo AS (
  SELECT
    sale_id,
    car_id,
    sale_price,
    sale_date
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
  WHERE sale_date BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'   --jan/2025 a dez/2025
)
SELECT
  c.make,
  c.model,
  AVG(p.sale_price) AS preco_medio_modelo
FROM periodo AS p
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS c
  USING (car_id)
GROUP BY c.make, c.model
HAVING AVG(p.sale_price) >
  (SELECT AVG(sale_price) FROM periodo)     --média global do período
ORDER BY preco_medio_modelo DESC
LIMIT 15;


-- ============================================================
-- 4) INLINE SUBQUERY + CTE de calendário (preenche zeros)
--    “Série diária + vendas por dia (preenche zeros)”
--    - CTE 'diario' cria datas contínuas via GENERATE_DATE_ARRAY.
--    - Inline subquery agrega vendas por dia e faz LEFT JOIN para preencher faltantes.
-- ============================================================
WITH diario AS (
  SELECT d AS dt
  FROM UNNEST(GENERATE_DATE_ARRAY(DATE '2025-01-01', DATE '2025-01-15')) AS d
)
SELECT
  d.dt,
  COALESCE(v.qtd, 0)     AS qtd,      --preenche zero onde não houve venda
  COALESCE(v.receita, 0) AS receita
FROM diario AS d
LEFT JOIN (
  SELECT
    DATE(sale_date)   AS dt,
    COUNT(*)          AS qtd,         --vendas por dia
    SUM(sale_price)   AS receita      --receita por dia
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
  WHERE DATE(sale_date) BETWEEN DATE '2025-01-01' AND DATE '2025-01-15'
  GROUP BY dt
) AS v
USING (dt)
ORDER BY d.dt;


-- ============================================================
-- Dicas de performance/custo (SUBQUERIES no BigQuery):
--    - EXISTS vs IN:
--        * EXISTS costuma ser preferível em verificações de “há pelo menos 1 linha”.
--        * IN é ótimo com listas pequenas ou quando a subconsulta já retorna chaves únicas.
--    - CTEs (WITH):
--        * São lógicas; o otimizador pode inlinar. Use para clareza e para forçar filtros de período.
--    - Subconsulta escalar:
--        * Avalie materializar valores globais (ex.: média do período) em CTE/param para reutilização.
--    - Calendário:
--        * GENERATE_DATE_ARRAY é ótimo para séries; mantenha janelas curtas para não expandir demais.
--    - Partição/Clustering:
--        * Empurre filtros por sale_date/hire_date para reduzir bytes lidos antes das subqueries/join.
--    - Projeção:
--        * Selecione apenas colunas necessárias dentro das subqueries para reduzir custo de shuffle/scan.
-- ============================================================
