-- ============================================================
--    Domínio:   Filtro por operadores LÓGICOS em vendas
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--               (sale_id, car_id, seller_id, store_id, sale_price, sale_date)
--    Observações:
--      - Demonstra uso de AND, OR, NOT e parênteses (precedência).
--      - Mantém a mesma lógica-base da consulta anterior, expandindo exemplos.
-- ============================================================

-- ============================================================
-- Operadores lógicos (recordatório):
--    AND  → todas as condições verdadeiras
--    OR   → ao menos uma condição verdadeira
--    NOT  → nega a condição seguinte
--    ( )  → altera a precedência (executa primeiro o que está entre parênteses)
--  Obs.: Precedência padrão: NOT > AND > OR.
-- ============================================================


-- ============================================================
-- Exemplo 1) AND + Precedência explícita com parênteses
--    - Idêntico à consulta anterior, só que com parênteses para didática.
-- ============================================================
SELECT
  f.sale_id,        --id da venda
  f.store_id,       --loja
  f.seller_id,      --vendedor
  f.car_id,         --carro
  f.sale_price,     --preço da venda
  f.sale_date       --data da venda
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
WHERE
  (f.store_id = 22)                 --igual
  AND (f.seller_id <> 1907)         --diferente
  AND (f.sale_price <= 158760)      --menor ou igual
ORDER BY f.sale_price DESC;          --decrescente (maior → menor)


-- ============================================================
-- Exemplo 2) AND + OR + NOT com parênteses para controlar a lógica
--    - Lógica: (loja 22 E vendedor ≠ 1907) OU (loja 23 E preço ≤ 158760)
--    - Exemplo de NOT: NOT (f.sale_price > 300000)  ≡  f.sale_price <= 300000
-- ============================================================
SELECT
  f.sale_id,
  f.store_id,
  f.seller_id,
  f.car_id,
  f.sale_price,
  f.sale_date
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
WHERE
  (
    (f.store_id = 22 AND f.seller_id <> 1907)   --bloco A
    OR
    (f.store_id = 23 AND f.sale_price <= 158760) --bloco B
  )
  AND NOT (f.sale_price > 300000)  --equivale a f.sale_price <= 300000
ORDER BY f.sale_price DESC;


-- ============================================================
-- Dicas de uso/otimização para operadores lógicos:
--    - SEMPRE use parênteses quando combinar AND/OR para evitar ambiguidades.
--    - Prefira comparações “positivas” a negações: (preco <= 300k) é mais claro
--      que NOT (preco > 300k); além de favorecer planos de execução mais simples.
--    - Evite NOT sobre colunas de partição/clustering: pode degradar o pruning.
--    - Quando OR espalha filtros em colunas distintas e a leitura fica pesada,
--      considere reescrever como UNION ALL de consultas mais seletivas.
--    - Documente a intenção do bloco lógico (comentários acima dos parênteses).
-- ============================================================
