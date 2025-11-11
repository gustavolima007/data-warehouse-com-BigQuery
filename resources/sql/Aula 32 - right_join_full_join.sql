-- ============================================================
-- CONTEXTO (Rox School Cars)
--   Fato:     bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--             (sale_id, car_id, seller_id, sale_price, sale_timestamp, ...)
--   Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_car
--   Dimensão: bigquery-iniciante-roxschool.roxschool_cars.dim_seller
-- ============================================================


-- ============================================================
-- RIGHT JOIN básico: "preserva a TABELA DA DIREITA"
--    Objetivo: listar TODOS os VENDEDORES, inclusive os sem venda.
--    Dica: poderia ser escrito como LEFT JOIN invertendo a ordem das tabelas.
-- ------------------------------------------------------------
-- RIGHT JOIN preserva 's' (direita). Onde não houver match, colunas de 'f' vêm NULL.
-- COUNT(f.sale_id) conta apenas quando há venda (NULLs não contam).
-- ============================================================
SELECT
  s.seller_id,
  s.seller_name,
  COUNT(f.sale_id) AS qtd_vendas
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`  AS f
RIGHT JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  ON s.seller_id = f.seller_id
GROUP BY s.seller_id, s.seller_name
ORDER BY qtd_vendas DESC, s.seller_name;


-- ============================================================
-- CUIDADO no RIGHT JOIN: filtros no WHERE podem "matar" a preservação
--    Objetivo: contar vendas > 100k por vendedor sem perder vendedores sem venda.
-- ------------------------------------------------------------
-- ERRADO: filtrar coluna da ESQUERDA (f.* ) no WHERE remove os NULLs de 'f'
--            e transforma na prática em INNER JOIN.
-- ============================================================
SELECT
  s.seller_id,
  s.seller_name,
  COUNT(f.sale_id) AS vendas_acima_100k
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
RIGHT JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  ON s.seller_id = f.seller_id
WHERE f.sale_price > 100000                 -- <- elimina linhas onde f.* é NULL
GROUP BY s.seller_id, s.seller_name;

-- CERTO (opção A): empurrar a condição para o ON
SELECT
  s.seller_id,
  s.seller_name,
  COUNT(f.sale_id) AS vendas_acima_100k
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
RIGHT JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  ON s.seller_id = f.seller_id
 AND f.sale_price > 100000                  -- preserva vendedores sem venda (f = NULL)
GROUP BY s.seller_id, s.seller_name;

-- CERTO (opção B): usar COUNTIF (condição na agregação)
SELECT
  s.seller_id,
  s.seller_name,
  COUNTIF(f.sale_price > 100000) AS vendas_acima_100k
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
RIGHT JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  ON s.seller_id = f.seller_id
GROUP BY s.seller_id, s.seller_name;


-- ============================================================
-- FULL OUTER JOIN: preserva AMBOS os lados
--    Objetivo: conciliar carros entre a dimensão e a fato agregada.
--    - "casados": existem nos dois lados
--    - "só na dimensão": não tem venda
--    - "só na fato": venda com car_id não cadastrado na dimensão (erro de DQ)
-- ------------------------------------------------------------
-- Boas práticas:
--   * Pré-agregue a fato para evitar multiplicar linhas.
--   * Use COALESCE para formar uma chave "comum" no resultado.
-- ============================================================
WITH vendas_por_carro AS (
  SELECT
    car_id,
    COUNT(*)        AS qtd_vendas,
    SUM(sale_price) AS receita_total
  FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
  WHERE sale_date BETWEEN '2025-01-01' AND DATE '2025-12-31'
  GROUP BY car_id
)
SELECT
  COALESCE(c.car_id, v.car_id) AS car_id,
  c.make,
  c.model,
  v.qtd_vendas,
  v.receita_total,
  CASE
    WHEN c.car_id IS NOT NULL AND v.car_id IS NOT NULL THEN 'MATCHED'
    WHEN c.car_id IS NOT NULL AND v.car_id IS NULL     THEN 'ONLY_DIM'   -- sem venda
    WHEN c.car_id IS NULL     AND v.car_id IS NOT NULL THEN 'ONLY_FACT'  -- fato órfã
  END AS status
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS c
FULL OUTER JOIN vendas_por_carro AS v
  ON v.car_id = c.car_id
ORDER BY status ASC, receita_total DESC NULLS LAST;


-- ============================================================
-- FULL OUTER JOIN focado em "só diferenças" (symmetric difference)
--    Objetivo: retornar apenas chaves sem correspondência em um dos lados.
-- ------------------------------------------------------------
-- Útil para auditorias (chaves órfãs ou dimensões não utilizadas).
-- ============================================================
WITH vendas_por_carro AS (
  SELECT car_id FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` GROUP BY car_id
)
SELECT
  COALESCE(c.car_id, v.car_id) AS car_id,
  CASE
    WHEN c.car_id IS NULL THEN 'ONLY_FACT'
    WHEN v.car_id IS NULL THEN 'ONLY_DIM'
  END AS status
FROM `roxschool_cars.dim_car` AS c
FULL OUTER JOIN vendas_por_carro AS v
  ON v.car_id = c.car_id
WHERE c.car_id IS NULL OR v.car_id IS NULL    -- mantém só as diferenças
ORDER BY status, car_id;


-- ============================================================
-- FULL OUTER JOIN com múltiplos atributos (vendedor)
--    Objetivo: conciliar vendedores entre dimensão e fato agregada,
--    e rotular a situação de cada vendedor no período.
-- ============================================================
WITH vendas_por_vendedor AS (
  SELECT
    seller_id,
    COUNT(*)        AS qtd_vendas,
    SUM(sale_price) AS receita_total
  FROM `roxschool_cars.fact_sales`
  WHERE sale_date >= '2025-01-01' AND sale_date <= '2025-12-31'
  GROUP BY seller_id
)
SELECT
  COALESCE(s.seller_id, v.seller_id) AS seller_id,
  s.seller_name,
  v.qtd_vendas,
  v.receita_total,
  CASE
    WHEN s.seller_id IS NOT NULL AND v.seller_id IS NOT NULL THEN 'MATCHED'
    WHEN s.seller_id IS NOT NULL AND v.seller_id IS NULL     THEN 'ONLY_DIM'
    WHEN s.seller_id IS NULL     AND v.seller_id IS NOT NULL THEN 'ONLY_FACT'
  END AS status
FROM `roxschool_cars.dim_seller` AS s
FULL OUTER JOIN vendas_por_vendedor AS v
  ON v.seller_id = s.seller_id
ORDER BY status, receita_total DESC NULLS LAST;


-- ============================================================
-- DICAS DE AULA / PERFORMANCE
--  * RIGHT JOIN é “espelho” do LEFT JOIN — prefira LEFT por legibilidade,
--    mas saiba ler RIGHT quando encontrar.
--  * FULL OUTER JOIN é excelente para reconciliação e auditoria de DQ.
--  * Pré-agregue a fato (CTE) antes de juntar: evita duplicação e reduz bytes lidos.
--  * Evite filtros no WHERE que eliminem NULLs do lado preservado:
--      - RIGHT JOIN: cuidado com filtros de colunas da ESQUERDA (f.*) no WHERE.
--      - FULL OUTER: qualquer filtro no WHERE pode descartar um dos lados;
--        prefira condicionar no ON ou usar COUNTIF/SUM(IF(...)).
-- ============================================================
