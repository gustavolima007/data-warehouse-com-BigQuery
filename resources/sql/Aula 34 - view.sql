-- ============================================================
--    Domínio:   Views no BigQuery (lógica x materializada)
--    Fato:      bigquery-iniciante-roxschool.roxschool_cars.fact_sales (sale_id, car_id, seller_id, sale_price, sale_date)
--    Dimensão:  bigquery-iniciante-roxschool.roxschool_cars.dim_car     (car_id, vin, make, model, year, color, base_price)
--    Objetivo:  Expor “vendas por marca (make)” via VIEW lógica e MATERIALIZED VIEW.
--    Observações:
--      - VIEW (lógica) apenas salva a consulta; lê a tabela base a cada execução.
--      - MATERIALIZED VIEW (MV) armazena resultados e pode atualizar automaticamente (enable_refresh).
-- ============================================================


-- ============================================================
-- VIEW LÓGICA (não materializa dados; sempre lê as tabelas base)
--    - Uso típico: camada semântica para BI/analistas.
-- ============================================================
CREATE VIEW `roxschool_cars.vw_sales_by_make` AS
SELECT
  c.make,
  COUNT(*) AS qtd_vendas               --contagem de vendas por marca
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY c.make;


-- ============================================================
-- MATERIALIZED VIEW (armazena resultados e pode autoatualizar)
--    - enable_refresh = false → sem atualização automática.
--    - Útil para acelerar dashboards recorrentes.
-- ============================================================
CREATE MATERIALIZED VIEW `roxschool_cars.vw_sales_by_make_materialized`
OPTIONS (enable_refresh = false) AS
SELECT
  c.make,
  COUNT(*) AS qtd_vendas               --contagem de vendas por marca
FROM `bigquery-iniciante-roxschool.roxschool_cars.fact_sales` AS f
JOIN `bigquery-iniciante-roxschool.roxschool_cars.dim_car`    AS c
  ON c.car_id = f.car_id
GROUP BY c.make;


-- ============================================================
-- REFRESH MANUAL DA MATERIALIZED VIEW
--    - Útil quando o auto-refresh está desativado.
--    - Use o nome totalmente qualificado (project.dataset.view).
-- ============================================================
CALL BQ.REFRESH_MATERIALIZED_VIEW(
  'bigquery-iniciante-roxschool.roxschool_cars.vw_sales_by_make_materialized'
);


-- ============================================================
-- ALTERAR OPÇÕES DA MATERIALIZED VIEW
--    - Habilita atualização automática (scheduler interno do BigQuery).
-- ============================================================
ALTER MATERIALIZED VIEW `roxschool_cars.vw_sales_by_make_materialized`
SET OPTIONS (enable_refresh = true);


-- ============================================================
-- Dicas práticas: Views (lógica x materializada)
--    - VIEW (lógica):
--        * Não reduz custo por si só; cada execução revarre as tabelas base.
--        * Boa para versionar regras de negócio e centralizar lógica SQL.
--    - MATERIALIZED VIEW:
--        * Acelera leituras repetidas; paga-se pelo armazenamento + manutenção.
--        * Para maior benefício, filtre por partição/clustering nas tabelas base
--          e mantenha a consulta da MV elegível a refresh incremental.
--        * Se o BI só pre*
