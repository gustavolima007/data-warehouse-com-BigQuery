-- ============================================================
--    Domínio:   Comandos DML (Data Manipulation Language)
--    Tabelas:   bigquery-iniciante-roxschool.roxschool_cars.dim_car
--               (car_id, vin, make, model, year, color, ...)
--    Observações:
--      - DML inclui SELECT, INSERT, UPDATE, DELETE e MERGE.
--      - Serve para consultar, inserir, atualizar ou excluir dados.
-- ============================================================


-- ============================================================
-- SELEÇÃO DE DADOS (SELECT)
--    - Recupera registros da tabela.
--    - WHERE filtra resultados conforme condições.
-- ============================================================
SELECT
  *
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
WHERE car_id = 8;


-- ============================================================
-- INSERÇÃO DE DADOS DIRETA (INSERT)
--    - Adiciona novos registros na tabela.
--    - Pode inserir uma ou várias linhas.
-- ============================================================

-- Inserção simples (uma linha)
INSERT INTO `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
(car_id, vin, make, model, year, color)
VALUES
  (10001, 'VIN-0001', 'Toyota', 'Corolla', 2024, 'Preto');


-- Inserção múltipla (várias linhas)
INSERT INTO `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
(car_id, vin, make, model, year, color)
VALUES
  (11000,  'VIN-0001', 'Toyota',     'Corolla', 2024, 'Preto'),
  (10002,  'VIN-0002', 'Honda',      'Civic',   2023, 'Prata'),
  (10003,  'VIN-0003', 'Volkswagen', 'Golf',    2022, 'Vermelho'),
  (10004,  'VIN-0004', 'Chevrolet',  'Onix',    2025, 'Branco'),
  (10005,  'VIN-0005', 'Ford',       'Focus',   2021, 'Azul'),
  (10006,  'VIN-0006', 'Hyundai',    'HB20',    2024, 'Cinza'),
  (10007,  'VIN-0007', 'Nissan',     'Sentra',  2022, 'Preto'),
  (10008,  'VIN-0008', 'Renault',    'Duster',  2023, 'Verde'),
  (10009,  'VIN-0009', 'Peugeot',    '208',     2024, 'Azul'),
  (10010,  'VIN-0010', 'Fiat',       'Argo',    2023, 'Branco');


-- ============================================================
-- INSERÇÃO A PARTIR DE OUTRA TABELA (INSERT INTO ... SELECT)
--    - Copia registros de outra tabela.
-- ============================================================
INSERT INTO `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
SELECT *
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
WHERE car_id = 8;


-- ============================================================
-- CTAS (CREATE TABLE AS SELECT) OU REPLACE
--    - Recria a tabela com dados atualizados.
--    - Pode aplicar filtros, transformações e UNIONs.
-- ============================================================
CREATE OR REPLACE TABLE `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS
SELECT *
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
WHERE car_id <> 8
UNION ALL
SELECT
  car_id, vin, make, model, 2018 AS year, color,
  body_type, transmission, fuel_type, condition, base_price
FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
WHERE car_id = 8;


-- ============================================================
-- MERGE (UPSERT → INSERT se não existir / UPDATE se já existir)
--    - Combina atualização e inserção na mesma operação.
-- ============================================================
MERGE `bigquery-iniciante-roxschool.roxschool_cars.dim_car` AS T
USING (
  SELECT * FROM UNNEST([
    STRUCT(1 AS car_id, 'VIN-0001' AS vin, 'Toyota'     AS make, 'Corolla' AS model, 2024 AS year, 'Preto'    AS color),
    STRUCT(2 AS car_id, 'VIN-0002' AS vin, 'Honda'      AS make, 'Civic'   AS model, 2023 AS year, 'Prata'    AS color),
    STRUCT(3 AS car_id, 'VIN-0003' AS vin, 'Volkswagen' AS make, 'Golf'    AS model, 2022 AS year, 'Vermelho' AS color),
    STRUCT(4 AS car_id, 'VIN-0004' AS vin, 'Chevrolet'  AS make, 'Onix'    AS model, 2025 AS year, 'Branco'   AS color),
    STRUCT(5 AS car_id, 'VIN-0005' AS vin, 'Ford'       AS make, 'Focus'   AS model, 2021 AS year, 'Azul'     AS color)
  ])
) AS S
ON T.car_id = S.car_id
WHEN MATCHED THEN
  UPDATE SET
    T.vin   = S.vin,
    T.make  = S.make,
    T.model = S.model,
    T.year  = S.year,
    T.color = S.color
WHEN NOT MATCHED THEN
  INSERT (car_id, vin, make, model, year, color)
  VALUES (S.car_id, S.vin, S.make, S.model, S.year, S.color);


-- ============================================================
-- ATUALIZAÇÃO DE DADOS (UPDATE)
--    - Altera valores existentes em registros que atendem a uma condição.
-- ============================================================
UPDATE `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
SET year = 2025
WHERE car_id = 8;


-- ============================================================
-- EXCLUSÃO DE DADOS (DELETE)
--    - Remove registros que atendem à condição especificada.
-- ============================================================
DELETE FROM `bigquery-iniciante-roxschool.roxschool_cars.dim_car`
WHERE car_id = 8;


-- ============================================================
-- DESCRIBE / INFORMATION_SCHEMA
--    - Consulta a estrutura (schema) da tabela no BigQuery.
-- ============================================================
SELECT *
FROM `bigquery-iniciante-roxschool.roxschool_cars.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'dim_car';


-- ============================================================
-- Dicas práticas sobre DML:
--    - DMLs em tabelas grandes consomem custo proporcional aos bytes alterados/lidos.
--    - Para grandes volumes, prefira CTAS/CREATE OR REPLACE (opera em lote e é mais eficiente).
--    - MERGE é ideal para cenários de integração incremental (UPSERT).
--    - UPDATE/DELETE exigem partição/clustering eficiente para custo baixo.
--    - Sempre teste SELECT antes de um UPDATE/DELETE para garantir o filtro correto.
-- ============================================================
