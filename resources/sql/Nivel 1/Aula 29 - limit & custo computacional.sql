-- ============================================================
--    Domínio:   Amostragem e limitação de resultados (LIMIT / TABLESAMPLE)
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales
--               (sale_id, car_id, seller_id, store_id, sale_price, sale_date, channel, quantity, ...)
--    Observações:
--      - LIMIT controla apenas a QUANTIDADE de linhas retornadas ao CLIENTE.
--      - Em geral, LIMIT não reduz bytes lidos/custos (a menos que combinado com filtros de partição/clustering).
--      - TABLESAMPLE SYSTEM (%) pode reduzir leitura de dados de forma APROXIMADA (amostra aleatória de blocos).
-- ============================================================


-- ============================================================
-- LIMIT simples (didático) — RUIM para custo (não filtra leitura)
--    - Útil para "espiar" o shape dos dados.
--    - Não reduz, em geral, os bytes lidos da tabela.
-- ============================================================
SELECT
  *
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
LIMIT 10;


-- ============================================================
-- Exemplo melhor para "olhar dados": TABLESAMPLE SYSTEM
--    - Amostra aproximada de blocos do armazenamento.
--    - Pode reduzir dados processados/custo, mas NÃO garante uniformidade estrita.
-- ============================================================
SELECT
  *
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
TABLESAMPLE SYSTEM (10 PERCENT);


-- ============================================================
-- Projeção econômica de colunas (evite SELECT *):
--    - EXCEPT remove colunas pouco úteis nesta inspeção.
--    - LIMIT apenas limita o retorno, não a leitura total.
-- ============================================================
SELECT
  * EXCEPT (channel, quantity)
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
LIMIT 10;


-- ============================================================
-- LIMIT com filtro de PARTIÇÃO (bom para custo se a tabela for particionada)
--    - Aqui, filtramos por janela de datas para reduzir leitura.
--    - Ajuste o intervalo às partições reais (ex.: por DAY/DATE).
-- ============================================================
SELECT
  sale_id, store_id, seller_id, car_id, sale_price, sale_date
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
WHERE sale_date BETWEEN DATE '2024-01-01' AND DATE '2024-01-31'
LIMIT 10;


-- ============================================================
-- Amostra determinística e barata (fingerprint hash % N)
--    - Evita ORDER BY RAND() (caro) para amostragem pseudo-aleatória.
--    - MOD(FARM_FINGERPRINT(...), 100) = 0  → ~1% da tabela.
-- ============================================================
SELECT
  sale_id, store_id, seller_id, car_id, sale_price, sale_date
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
WHERE MOD(ABS(FARM_FINGERPRINT(CAST(sale_id AS STRING))), 100) = 0
LIMIT 100;


-- ============================================================
-- LIMIT + ORDER BY (Top-N) — reduz custo de ordenação, não de leitura
--    - BigQuery otimiza Top-N; ainda assim, LEITURA integral se não houver filtro seletivo.
-- ============================================================
SELECT
  sale_id, car_id, sale_price, sale_date
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales`
WHERE sale_date >= DATE '2024-01-01'          --ajude o pruning de partição
ORDER BY sale_price DESC
LIMIT 20;


-- ============================================================
-- Dicas específicas sobre LIMIT / TABLESAMPLE:
--    - LIMIT não reduz bytes lidos; combine com WHERE (partição/clustering) para economizar.
--    - TABLESAMPLE SYSTEM (%) pode reduzir leitura, mas é aproximado e não garante uniformidade perfeita.
--    - Para amostras reproduzíveis e baratas, use hash determinístico (FARM_FINGERPRINT) em vez de RAND().
--    - Evite SELECT *: projete só as colunas necessárias; use INCLUDE/EXCLUDE (SELECT * EXCEPT (...)) com parcimônia.
--    - Para Top-N, prefira ORDER BY <métrica> DESC LIMIT N + filtro de partição para minimizar varredura.
-- ============================================================