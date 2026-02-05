-- ============================================================
--   Fato:     bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--             (sale_id, car_id, seller_id, sale_price, sale_timestamp, ...)
--   Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_car
--             (car_id, vin, make, model, year, color)
--   Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_seller
--             (seller_id, seller_name, store_id, hire_date)
-- ============================================================

-- ============================================================
-- INNER JOIN básico (somente linhas que “batem” nas duas tabelas)
--    Objetivo: listar as 20 vendas mais caras desde 01/01/2025,
--    trazendo atributos do carro (make/model).
-- ------------------------------------------------------------
-- SELECT: escolhe colunas (dimensões e métricas)
-- FROM:   começa na fato (eventos de venda)
-- JOIN:   junta a dimensão de carro via chave car_id
-- WHERE:  filtra linhas ANTES de qualquer agregação
-- ORDER:  ordena pelo preço descrescente (do maior para o menor)
-- LIMIT:  devolve apenas as top 20 linhas
-- ============================================================
SELECT
  f.sale_id,
  c.make,
  c.model,
  f.sale_price
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`  AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c
  ON c.car_id = f.car_id                            -- condição de igualdade (chave)
WHERE f.sale_date >= '2025-01-01'   -- filtro linha-a-linha
ORDER BY f.sale_price DESC
LIMIT 20;

-- ============================================================
-- INNER JOIN com múltiplas dimensões + agregação
--    Objetivo: para vendas acima de 80k, contar quantas vendas houve
--    por (marca, modelo) e calcular preço médio.
-- ------------------------------------------------------------
-- USING(col) é um atalho quando a coluna tem o mesmo nome nos dois lados.
-- GROUP BY define o nível de detalhe (make, model).
-- ORDER BY usa o alias de agregação (qtd_vendas).
-- ============================================================
SELECT
  c.make, c.model,
  COUNT(*)          AS qtd_vendas,
  AVG(f.sale_price) AS preco_medio
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c  USING (car_id)
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s  USING (seller_id)
WHERE f.sale_price > 80000
GROUP BY c.make, c.model
ORDER BY qtd_vendas DESC;

-- ============================================================
-- LEFT JOIN (preserva a tabela da ESQUERDA)
--    Objetivo: listar TODOS os carros, inclusive os que nunca venderam,
--    contando quantas vendas cada um tem.
-- ------------------------------------------------------------
-- LEFT JOIN preserva as linhas de 'c' (dim_car).
-- Se não houver match na fato, colunas de 'f' vêm como NULL.
-- COUNT(f.sale_id) conta somente quando existe venda (NULLs não contam).
-- ============================================================
SELECT
  c.car_id,
  c.make, c.model, c.year,
  COUNT(f.sale_id) AS qtd_vendas
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`         AS c
LEFT JOIN `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`  AS f
  ON f.car_id = c.car_id
GROUP BY c.car_id, c.make, c.model, c.year
ORDER BY qtd_vendas DESC, c.make, c.model;


-- ============================================================
-- CUIDADO CLÁSSICO: filtro no WHERE pode “matar” o LEFT JOIN
--    Objetivo: contar vendas acima de 100k por carro SEM perder os carros
--    que não tiveram vendas (neste caso, o resultado deveria ser zero).
-- ------------------------------------------------------------
-- ERRADO: colocar a condição de preço no WHERE elimina NULLs e
--            transforma o LEFT JOIN na prática em INNER JOIN.
-- ============================================================
SELECT
  c.car_id, c.make,
  COUNT(f.sale_id) AS qtd_vendas_alto_preco
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`        AS c
LEFT JOIN `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
  ON f.car_id = c.car_id
WHERE f.sale_price > 100000                -- <- remove NULLs; some quem não tem venda
GROUP BY c.car_id, c.make;

-- CERTO (opção A): usar COUNTIF para contar condicionalmente,
--     preservando as linhas sem venda.
SELECT
  c.car_id, c.make,
  COUNTIF(f.sale_price > 100000) AS qtd_vendas_alto_preco
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`        AS c
LEFT JOIN `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
  ON f.car_id = c.car_id
GROUP BY c.car_id, c.make;

-- CERTO (opção B): empurrar a condição para o ON e contar normalmente.
--     Aqui, o join só “pega” vendas > 100k; onde não houver, f.* será NULL.
SELECT
  c.car_id, c.make,
  COUNT(f.sale_id) AS qtd_vendas_alto_preco
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`        AS c
LEFT JOIN `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
  ON f.car_id = c.car_id
 AND f.sale_price > 100000                   -- <- condição no ON preserva o LEFT
GROUP BY c.car_id, c.make;


-- ============================================================
-- LEFT ANTI-JOIN (encontrar dimensões “sem fato”)
--    Objetivo: listar carros que nunca tiveram venda.
-- ------------------------------------------------------------
-- Padrão: LEFT JOIN + filtro IS NULL nas colunas da fato.
-- ============================================================
SELECT
  c.car_id, c.make, c.model, c.year
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`         AS c
LEFT JOIN `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`  AS f
  ON f.car_id = c.car_id
WHERE f.car_id IS NULL;     -- só ficam os que não casaram com a fato


-- ============================================================
-- Pré-agregação antes do JOIN (evitar duplicações e acelerar)
--    Objetivo: agregar a fato por car_id (qtd + receita) com filtro de data,
--    e só então “dimensionalizar” na dim_car.
-- ------------------------------------------------------------
-- Benefícios:
--   - menos linhas no join (mais rápido/mais barato);
--   - evita multiplicar linhas quando há múltiplas dimensões depois.
-- ============================================================
WITH vendas_por_carro AS (
  SELECT
    car_id,
    COUNT(*)        AS qtd_vendas,
    SUM(sale_price) AS receita_total
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
  WHERE sale_date BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
  GROUP BY car_id
)
SELECT
  c.car_id, c.make, c.model,
  v.qtd_vendas, v.receita_total
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS c
LEFT JOIN vendas_por_carro AS v USING (car_id)
ORDER BY v.receita_total DESC NULLS LAST;


-- ============================================================
-- DICAS FINAIS (performance e custo)
--  * Sempre projete só as colunas necessárias (evite SELECT *).
--  * Use filtros de partição (ex.: WHERE DATE(sale_timestamp) >= ...) ANTES do JOIN.
--  * Em LEFT JOIN, prefira COUNTIF / SUM(IF(...)) para métricas condicionais.
--  * Se a tabela for clusterizada pelas chaves de join/filtro, os scans tendem a ser menores.
-- ============================================================
