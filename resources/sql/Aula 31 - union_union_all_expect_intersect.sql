-- ============================================================
--    Domínio:   Operadores de conjuntos (UNION/EXCEPT/INTERSECT) no BigQuery
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales (sale_id, car_id, sale_price, sale_date)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_car     (car_id, make, model, ...)
--    Objetivo:  Empilhar, unificar, subtrair e intersectar resultados entre anos.
--    Observações:
--      - BigQuery: UNION (sem ALL) ≡ UNION DISTINCT (remove duplicidades).
--      - ORDER BY só é permitido no FINAL de um conjunto (após o último SELECT).
-- ============================================================


-- ============================================================
-- UNION ALL — Empilhar e manter duplicidades (rotulando a origem)
--    - Empilha vendas de 2024 e 2025, preservando duplicidades.
-- ============================================================
SELECT '2024' AS origem, f.sale_id, c.make, c.model, f.sale_price
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2024

UNION ALL

SELECT '2025' AS origem, f.sale_id, c.make, c.model, f.sale_price
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2025

ORDER BY sale_price DESC
LIMIT 20;


-- ============================================================
-- UNION DISTINCT — Unir conjuntos removendo duplicidades
--    - Resultado único de (make, model) com vendas em 2024 OU 2025.
--    - Em BigQuery, UNION ≡ UNION DISTINCT (mantido explícito para didática).
-- ============================================================
SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2024

UNION DISTINCT   -- UNION tradicional (remove duplicatas)

SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2025

ORDER BY make, model;


-- ============================================================
-- EXCEPT DISTINCT — A menos B (itens de A que NÃO estão em B)
--    - A: modelos vendidos em 2024
--    - B: modelos vendidos em 2025
-- ============================================================
SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2024

EXCEPT DISTINCT

SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2025

ORDER BY make, model;


-- ============================================================
-- INTERSECT DISTINCT — Interseção (itens presentes em A E em B)
--    - A: modelos vendidos em 2024
--    - B: modelos vendidos em 2023
-- ============================================================
SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2024

INTERSECT DISTINCT

SELECT DISTINCT c.make, c.model
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`     AS c USING (car_id)
WHERE EXTRACT(YEAR FROM f.sale_date) = 2023

ORDER BY make, model;


-- ============================================================
-- Dicas de performance/custo (sets):
--    - Prefira UNION ALL quando não precisar deduplicar (mais barato e rápido).
--    - Alinhe schemas: mesma quantidade/ordem de colunas e tipos compatíveis.
--    - Empurre filtros por partição (ex.: YEAR(sale_date)) em cada SELECT antes do set.
--    - Quando usar UNION/EXCEPT/INTERSECT DISTINCT em grandes volumes,
--      considere pré-aplicar DISTINCT nos inputs para reduzir custo da deduplicação final.
--    - Se ORDER BY/LIMIT forem necessários, mantenha-os só no final do conjunto.
-- ============================================================
