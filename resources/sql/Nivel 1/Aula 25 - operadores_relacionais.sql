-- ============================================================
--    Domínio:   Filtro por operadores relacionais em vendas
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--               (sale_id, car_id, seller_id, store_id, sale_price, sale_date)
--    Observações:
--      - Demonstra uso de operadores relacionais em múltiplas colunas.
--      - Ordena por preço de venda (DESC).
-- ============================================================

-- ============================================================
-- Operadores relacionais (recordatório):
--    <  menor      >  maior      <= menor ou igual    >= maior ou igual
--    =  igual      != diferente  <> diferente (equivalente ao !=)
-- ============================================================

-- ============================================================
-- Filtro por loja, vendedor (diferente) e teto de preço
--    - WHERE combina condições com AND.
--    - ORDER BY classifica do maior preço para o menor.
-- ============================================================
SELECT
  f.sale_id,        --identificador da venda
  f.store_id,       --loja
  f.seller_id,      --vendedor
  f.car_id,         --carro vendido
  f.sale_price,     --preço da venda
  f.sale_date       --data da venda
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
WHERE
  f.store_id = 22        --igual
  AND f.seller_id <> 1907 --diferente (<> equivalente a !=)
  AND f.sale_price <= 158760 --menor ou igual
ORDER BY
  f.sale_price DESC;      --decrescente (maior → menor)

-- ============================================================
-- Dicas de performance/custo:
--    - Projete só as colunas necessárias (evite SELECT *).
--    - Se houver partição por sale_date, use-a em filtros para reduzir leitura.
--    - Garanta estatísticas atualizadas e chaves inteiras para filtros/joins.
--    - Combine filtros seletivos antes de operações caras (JOIN/AGGREGATE).
-- ============================================================
