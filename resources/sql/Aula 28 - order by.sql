-- ============================================================
--    Domínio:   Consulta de catálogo de veículos (filtrar/ordenar)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_car
--               (make, model, year, color, base_price)
--    Observações:
--      - Demonstra filtro por ano e ordenação por múltiplas colunas.
--      - Exemplo de uso combinado de DESC (decrescente) e ASC (crescente).
-- ============================================================

-- ============================================================
-- Ordenação com ORDER BY múltiplas colunas (DESC/ASC)
--    - Primeiro: maior preço → menor (DESC).
--    - Depois: modelo em ordem alfabética (ASC) para empates.
-- ============================================================
SELECT
  c.base_price,      --preço base do veículo
  c.make,            --marca
  c.model            --modelo
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS c
WHERE c.year = 2018  --filtra apenas veículos do ano de 2018
ORDER BY
  c.base_price DESC, --ordem decrescente (maior → menor)
  c.model ASC;       --ordem crescente (A → Z) para desempate

-- ============================================================
-- Dicas de performance/custo:
--    - Projete só as colunas necessárias (evite SELECT *).
--    - Se a tabela for particionada por ano, use o campo de partição
--      no WHERE para reduzir varredura de dados.
--    - Para ordenações frequentes, avalie clustering por (year, base_price).
-- ============================================================