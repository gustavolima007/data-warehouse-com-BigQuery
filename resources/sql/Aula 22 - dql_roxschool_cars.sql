-- ============================================================
--    Domínio:   Vendas por Marca/Modelo/Vendedor/Loja (agregações)
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--               (sale_id, car_id, seller_id, store_id, sale_price, sale_date)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_car
--               (car_id, vin, make, model, year, color, ...)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_seller
--               (seller_id, seller_name, store_id, hire_date, ...)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_store
--               (store_id, store_name, city, state, ...)
--    Observações:
--      - Exemplo completo de SELECT → JOINs → WHERE → GROUP BY/HAVING → ORDER BY → LIMIT.
--      - HAVING aplica filtros sobre agregações; WHERE aplica antes do agrupamento.
-- ============================================================

-- ============================================================
-- Seleção das colunas de saída (dimensões + métricas)
--    - Dimensões: make, model, seller_name, store_name.
--    - Métricas: qtd_vendas, receita_total, preco_medio.
-- ============================================================
SELECT
  c.make,                        --dimensão (marca)
  c.model,                       --dimensão (modelo)
  s.seller_name,                 --dimensão (vendedor)
  st.store_name,                 --dimensão (loja)
  COUNT(*)          AS qtd_vendas,      --métrica: contagem de vendas
  SUM(f.sale_price) AS receita_total,   --métrica: soma do preço
  AVG(f.sale_price) AS preco_medio      --métrica: média do preço

-- ============================================================
-- Origem dos dados e relacionamentos (JOINs)
--    - Fato liga nas dimensões por chaves.
--    - Se a fato tiver store_id direto, pode-se ligar st.store_id = f.store_id.
-- ============================================================
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_seller` AS s
  ON s.seller_id = f.seller_id
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_store`  AS st
  ON st.store_id = s.store_id    --alternativa: st.store_id = f.store_id (se existir na fato)

-- ============================================================
-- Parâmetros de busca (pré-agrupamento)
--    - WHERE filtra linhas antes do GROUP BY.
-- ============================================================
WHERE
  c.year BETWEEN 2023 AND 2025   --intervalo de anos

-- ============================================================
-- Agrupamento e filtro pós-agregação
--    - GROUP BY define os níveis de detalhe.
--    - HAVING filtra por métricas agregadas (ex.: soma > 50k).
-- ============================================================
GROUP BY
  c.make, c.model, s.seller_name, st.store_name
HAVING
  SUM(f.sale_price) > 50000

-- ============================================================
-- Ordenação e limitação de linhas
--    - ORDER BY pode usar aliases definidos no SELECT.
--    - LIMIT limita a quantidade de linhas retornadas (Top-N).
-- ============================================================
ORDER BY
  receita_total DESC,
  qtd_vendas DESC
LIMIT 10;

-- ============================================================
-- Dicas de performance/custo (agregações e joins):
--    - Projete apenas colunas necessárias (evite SELECT *) para reduzir bytes lidos.
--    - Empurre filtros seletivos no WHERE (especialmente por partição/clustering) antes do GROUP BY.
--    - Confirme chaves de junção: use tipos inteiros e cardinalidades corretas para evitar explosão de linhas.
--    - Para Top-N, combine filtro de partição + ORDER BY métrica DESC + LIMIT para reduzir custo de ordenação.
--    - Se o mesmo relatório rodar com frequência, avalie materializar resultados (tabela/visão materializada).
-- ============================================================
