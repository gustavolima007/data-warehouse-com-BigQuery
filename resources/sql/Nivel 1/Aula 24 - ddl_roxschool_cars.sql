-- =========================================
-- 0) DATASET
-- =========================================
CREATE SCHEMA IF NOT EXISTS `roxschool_cars`
OPTIONS(location = "US");

-- =========================================
-- 1) DDL – Tabelas (Star Schema)
-- =========================================

-- Dimensão de Lojas
CREATE TABLE IF NOT EXISTS `roxschool_cars.dim_store` (
  store_id      INT64 NOT NULL,
  store_code    STRING,
  store_name    STRING,
  city          STRING,
  state         STRING,           -- UF (SP, RJ, MG)
  manufacturer  STRING,           -- montadora associada
  opened_date   DATE,
  is_flagship   BOOL
);


-- Dimensão de Vendedores
CREATE TABLE IF NOT EXISTS `roxschool_cars.dim_seller` (
  seller_id   INT64 NOT NULL,
  seller_code STRING,
  seller_name STRING,
  hire_date   DATE,
  email       STRING,
  phone       STRING,
  store_id    INT64 NOT NULL      -- FK para dim_store
);

-- Dimensão de Carros
CREATE TABLE IF NOT EXISTS `roxschool_cars.dim_car` (
  car_id        INT64 NOT NULL,
  vin           STRING,           -- pseudo VIN
  make          STRING,           -- marca
  model         STRING,           -- modelo
  year          INT64,
  color         STRING,
  body_type     STRING,           -- hatch/sedan/suv/pickup
  transmission  STRING,           -- manual/automatic
  fuel_type     STRING,           -- flex/gasolina/diesel/eletrico/hibrido
  condition     STRING,           -- novo/usado
  base_price    NUMERIC
);

-- Dimensão de Datas
CREATE TABLE IF NOT EXISTS `roxschool_cars.dim_date` (
  date_id     DATE NOT NULL,
  year        INT64,
  quarter     INT64,
  month       INT64,
  day         INT64,
  week        INT64,
  day_of_week INT64,
  is_weekend  BOOL
);

DROP TABLE IF EXISTS `roxschool_cars.fact_sales`;

CREATE TABLE `roxschool_cars.fact_sales` (
  sale_id           INT64,
  sale_date         DATE,
  store_id          INT64,
  seller_id         INT64,
  car_id            INT64,
  quantity          INT64,
  sale_price        NUMERIC,
  discount_value    NUMERIC,
  payment_type      STRING,
  channel           STRING,
  warranty_months   INT64,
  extended_warranty BOOL
)
PARTITION BY sale_date
CLUSTER BY store_id, seller_id, car_id;


-- =========================================
-- 2) DML – Popular Dimensões
--    (IMPORTANTE: INSERT INTO ... WITH ... SELECT ...)
-- =========================================

-- 2.1) Lojas (36 lojas; 3 estados; 10 cidades; múltiplas montadoras)
TRUNCATE TABLE `roxschool_cars.dim_store`;

INSERT INTO `roxschool_cars.dim_store`
WITH states AS (
  SELECT 'SP' AS uf, ['São Paulo','Campinas','Santos','Sorocaba'] AS cities UNION ALL
  SELECT 'RJ' AS uf, ['Rio de Janeiro','Niterói','Campos dos Goytacazes'] AS cities UNION ALL
  SELECT 'MG' AS uf, ['Belo Horizonte','Uberlândia','Juiz de Fora'] AS cities
),
manufacturers AS (
  SELECT manufacturer
  FROM UNNEST(['Toyota','Volkswagen','Chevrolet','Fiat','Hyundai','Jeep','Honda','Nissan']) AS manufacturer
),
store_base AS (
  SELECT
    ROW_NUMBER() OVER() AS store_id,
    CONCAT('LOJ', FORMAT('%03d', ROW_NUMBER() OVER())) AS store_code,
    CONCAT('Rox Motors ', manufacturer, ' - ', city) AS store_name,
    city,
    uf AS state,
    manufacturer,
    DATE_ADD(DATE '2018-01-01',
             INTERVAL CAST(ABS(MOD(FARM_FINGERPRINT(CONCAT(city, manufacturer)), 1800)) AS INT64) DAY) AS opened_date,
    MOD(ROW_NUMBER() OVER(), 12) = 0 AS is_flagship
  FROM states, UNNEST(cities) AS city
  CROSS JOIN manufacturers
  LIMIT 36
)
SELECT * FROM store_base
ORDER BY store_id;

-- 2.2) Vendedores (~4 por loja; ~120 total)
TRUNCATE TABLE `roxschool_cars.dim_seller`;

INSERT INTO `roxschool_cars.dim_seller`
WITH first_names AS (
  SELECT name AS first_name
  FROM UNNEST(['Ana','Bruno','Carla','Diego','Eduarda','Felipe','Gustavo',
               'Helena','Igor','Juliana','Karina','Lucas','Marina',
               'Natan','Paula','Rafael','Sofia','Tiago','Vanessa','Wagner']) AS name
),
last_names AS (
  SELECT name AS last_name
  FROM UNNEST(['Silva','Santos','Oliveira','Souza','Lima','Pereira',
               'Ferreira','Almeida','Gomes','Ribeiro','Carvalho','Rocha']) AS name
),
base AS (
  SELECT store_id FROM `roxschool_cars.dim_store`
),
sellers AS (
  SELECT
    ROW_NUMBER() OVER() AS seller_id,
    CONCAT('SEL', FORMAT('%04d', ROW_NUMBER() OVER())) AS seller_code,
    CONCAT(first_name, ' ', last_name) AS seller_name,
    DATE_ADD(DATE '2019-01-01',
             INTERVAL CAST(ABS(MOD(FARM_FINGERPRINT(CONCAT(first_name,last_name,CAST(store_id AS STRING))), 1500)) AS INT64) DAY) AS hire_date,
    CONCAT(LOWER(first_name), '.', LOWER(last_name), '@roxschool.com') AS email,
    CONCAT('+55', CAST(11 + MOD(store_id, 8) AS STRING),
           CAST(900000000 + ABS(MOD(FARM_FINGERPRINT(CONCAT(first_name,last_name,CAST(store_id AS STRING))), 99999999)) AS STRING)) AS phone,
    store_id
  FROM base
  CROSS JOIN first_names
  CROSS JOIN last_names
)
SELECT * FROM sellers
WHERE MOD(seller_id, 9) < 4   -- ~4 por loja
ORDER BY seller_id;

-- 2.3) Carros (~800) sem OFFSET dinâmico
TRUNCATE TABLE `roxschool_cars.dim_car`;

INSERT INTO `roxschool_cars.dim_car`
WITH makes AS (
  SELECT 'Toyota'  AS make, ['Corolla','Yaris','Hilux','SW4'] AS models UNION ALL
  SELECT 'Volkswagen', ['Gol','Polo','T-Cross','Saveiro'] UNION ALL
  SELECT 'Chevrolet', ['Onix','Tracker','S10','Equinox'] UNION ALL
  SELECT 'Fiat', ['Argo','Cronos','Pulse','Toro'] UNION ALL
  SELECT 'Hyundai', ['HB20','Creta','Santa Fe'] UNION ALL
  SELECT 'Jeep', ['Renegade','Compass'] UNION ALL
  SELECT 'Honda', ['Civic','City','HR-V'] UNION ALL
  SELECT 'Nissan', ['Kicks','Versa','Frontier']
),
colors AS (SELECT color FROM UNNEST(['preto','branco','prata','vermelho','azul','cinza','verde']) AS color),
body   AS (SELECT body_type FROM UNNEST(['hatch','sedan','suv','pickup']) AS body_type),
trans  AS (SELECT transmission FROM UNNEST(['manual','automatic']) AS transmission),
fuel   AS (SELECT fuel_type FROM UNNEST(['flex','gasolina','diesel','eletrico','hibrido']) AS fuel_type),

-- índices determinísticos por hash (evita OFFSET)
expanded AS (
  SELECT id AS car_id FROM UNNEST(GENERATE_ARRAY(1, 800)) AS id
),
idx AS (
  SELECT
    e.car_id,
    ABS(MOD(FARM_FINGERPRINT(CAST(e.car_id AS STRING)), 8))  AS idx_make,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('model',CAST(e.car_id AS STRING))), 4)) AS idx_model,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('color',CAST(e.car_id AS STRING))), 7)) AS idx_color,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('body',CAST(e.car_id AS STRING))), 4))  AS idx_body,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('trans',CAST(e.car_id AS STRING))), 2)) AS idx_trans,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('fuel',CAST(e.car_id AS STRING))), 5))  AS idx_fuel,
    ABS(MOD(FARM_FINGERPRINT(CONCAT('year',CAST(e.car_id AS STRING))), 11)) AS idx_year
  FROM expanded e
),

-- escolhe a make por rn
pick_make AS (
  SELECT
    i.car_id,
    m.make,
    i.idx_model, i.idx_color, i.idx_body, i.idx_trans, i.idx_fuel, i.idx_year
  FROM idx i
  JOIN (
    SELECT make, ROW_NUMBER() OVER (ORDER BY make) - 1 AS rn
    FROM makes
  ) m
  ON m.rn = i.idx_make
),

-- escolhe o model por rn dentro da make
pick_model AS (
  SELECT
    pm.car_id,
    pm.make,
    md.model,
    pm.idx_color, pm.idx_body, pm.idx_trans, pm.idx_fuel, pm.idx_year
  FROM pick_make pm
  JOIN (
    SELECT make, model
    FROM makes, UNNEST(models) AS model
  ) md
  ON md.make = pm.make
  QUALIFY ROW_NUMBER() OVER (PARTITION BY pm.car_id ORDER BY md.model) = pm.idx_model + 1
),

-- escolhe atributos restantes por rn
pick_color AS (
  SELECT
    p.car_id, p.make, p.model,
    c.color,
    p.idx_body, p.idx_trans, p.idx_fuel, p.idx_year
  FROM pick_model p
  JOIN (
    SELECT color, ROW_NUMBER() OVER (ORDER BY color) - 1 AS rn
    FROM colors
  ) c
  ON c.rn = p.idx_color
),
pick_body AS (
  SELECT
    p.car_id, p.make, p.model, p.color,
    b.body_type,
    p.idx_trans, p.idx_fuel, p.idx_year
  FROM pick_color p
  JOIN (
    SELECT body_type, ROW_NUMBER() OVER (ORDER BY body_type) - 1 AS rn
    FROM body
  ) b
  ON b.rn = p.idx_body
),
pick_trans AS (
  SELECT
    p.car_id, p.make, p.model, p.color, p.body_type,
    t.transmission,
    p.idx_fuel, p.idx_year
  FROM pick_body p
  JOIN (
    SELECT transmission, ROW_NUMBER() OVER (ORDER BY transmission) - 1 AS rn
    FROM trans
  ) t
  ON t.rn = p.idx_trans
),
pick_fuel AS (
  SELECT
    p.car_id, p.make, p.model, p.color, p.body_type, p.transmission,
    f.fuel_type,
    2015 + p.idx_year AS year
  FROM pick_trans p
  JOIN (
    SELECT fuel_type, ROW_NUMBER() OVER (ORDER BY fuel_type) - 1 AS rn
    FROM fuel
  ) f
  ON f.rn = p.idx_fuel
),

priced AS (
  SELECT
    car_id, make, model, year, color, body_type, transmission, fuel_type,
    CASE body_type
      WHEN 'pickup' THEN 140000
      WHEN 'suv'    THEN 120000
      WHEN 'sedan'  THEN 100000
      ELSE 80000
    END
    + (year - 2015) * 3500
    + CASE fuel_type WHEN 'eletrico' THEN 30000 WHEN 'hibrido' THEN 15000 ELSE 0 END
    - CASE WHEN transmission = 'manual' THEN 5000 ELSE 0 END AS base_price,
    CASE WHEN year >= 2023 THEN 'novo' ELSE 'usado' END AS condition
  FROM pick_fuel
)
SELECT
  car_id,
  CONCAT('VIN', FORMAT('%016x', ABS(FARM_FINGERPRINT(CAST(car_id AS STRING))))) AS vin,
  make, model, year, color, body_type, transmission, fuel_type,
  condition, CAST(base_price AS NUMERIC) AS base_price
FROM priced
ORDER BY car_id;

-- 2.4) Datas (2023-01-01..2025-12-31)
TRUNCATE TABLE `roxschool_cars.dim_date`;

INSERT INTO `roxschool_cars.dim_date`
SELECT
  d AS date_id,
  EXTRACT(YEAR FROM d)    AS year,
  EXTRACT(QUARTER FROM d) AS quarter,
  EXTRACT(MONTH FROM d)   AS month,
  EXTRACT(DAY FROM d)     AS day,
  EXTRACT(WEEK FROM d)    AS week,
  EXTRACT(DAYOFWEEK FROM d) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM d) IN (1,7) AS is_weekend
FROM UNNEST(GENERATE_DATE_ARRAY('2023-01-01','2025-12-31')) AS d;

-- =========================================
-- 3) DML – Popular Fato (~5.000 vendas)
-- =========================================
TRUNCATE TABLE `roxschool_cars.fact_sales`;

INSERT INTO `roxschool_cars.fact_sales` (
  sale_id, sale_date, store_id, seller_id, car_id, quantity,
  sale_price, discount_value, payment_type, channel, warranty_months, extended_warranty
)
WITH sales AS (
  SELECT id AS sale_id
  FROM UNNEST(GENERATE_ARRAY(1, 5000)) AS id
),
pick AS (
  SELECT
    s.sale_id,
    -- Corrigido: usar DATE_ADD para manter tipo DATE
    DATE_ADD(DATE '2023-01-01',
             INTERVAL CAST(ABS(MOD(FARM_FINGERPRINT(CONCAT('d',CAST(s.sale_id AS STRING))), 975)) AS INT64) DAY) AS sale_date,
    1 + ABS(MOD(FARM_FINGERPRINT(CONCAT('st',CAST(s.sale_id AS STRING))),
                (SELECT COUNT(*) FROM `roxschool_cars.dim_store`)))  AS store_id,
    1 + ABS(MOD(FARM_FINGERPRINT(CONCAT('se',CAST(s.sale_id AS STRING))),
                (SELECT COUNT(*) FROM `roxschool_cars.dim_seller`))) AS seller_id,
    1 + ABS(MOD(FARM_FINGERPRINT(CONCAT('ca',CAST(s.sale_id AS STRING))),
                (SELECT COUNT(*) FROM `roxschool_cars.dim_car`)))    AS car_id,
    1 AS quantity,
    CAST(ABS(MOD(FARM_FINGERPRINT(CONCAT('disc',CAST(s.sale_id AS STRING))), 13)) AS NUMERIC) AS discount_pct_bucket,
    (SELECT x FROM UNNEST(['loja','online','feirao']) AS x WITH OFFSET off
      WHERE off = ABS(MOD(FARM_FINGERPRINT(CONCAT('ch',CAST(s.sale_id AS STRING))), 3))) AS channel,
    (SELECT x FROM UNNEST(['vista','financiamento','consorcio','pix','cartao']) AS x WITH OFFSET off
      WHERE off = ABS(MOD(FARM_FINGERPRINT(CONCAT('pay',CAST(s.sale_id AS STRING))), 5))) AS payment_type,
    12 + ABS(MOD(FARM_FINGERPRINT(CONCAT('war',CAST(s.sale_id AS STRING))), 37)) AS warranty_months,
    MOD(s.sale_id, 5) = 0 AS extended_warranty
  FROM sales s
),
priced AS (
  SELECT
    p.*,
    c.base_price,
    (1 + (CAST(ABS(MOD(FARM_FINGERPRINT(CONCAT('adj',CAST(p.sale_id AS STRING))), 21)) AS NUMERIC) - 10) / 100) AS adj_factor,
    CAST(discount_pct_bucket / 100 AS NUMERIC) AS discount_pct
  FROM pick p
  JOIN `roxschool_cars.dim_car` c ON c.car_id = p.car_id
)
SELECT
  sale_id, sale_date, store_id, seller_id, car_id, quantity,
  ROUND(base_price * adj_factor, 2) AS sale_price,
  ROUND(base_price * adj_factor * discount_pct, 2) AS discount_value,
  payment_type, channel, warranty_months, extended_warranty
FROM priced
ORDER BY sale_id;

-- =========================================
-- 4) Views úteis (opcionais)
-- =========================================
CREATE OR REPLACE VIEW `roxschool_cars.vw_sales_enriched` AS
SELECT
  f.sale_id, f.sale_date,
  st.state, st.city, st.manufacturer AS store_manufacturer, st.store_name,
  se.seller_name,
  c.make, c.model, c.year, c.color, c.body_type, c.condition,
  f.quantity, f.sale_price, f.discount_value,
  f.payment_type, f.channel, f.warranty_months, f.extended_warranty
FROM `roxschool_cars.fact_sales` f
JOIN `roxschool_cars.dim_store`  st ON st.store_id  = f.store_id
JOIN `roxschool_cars.dim_seller` se ON se.seller_id = f.seller_id
JOIN `roxschool_cars.dim_car`    c  ON c.car_id    = f.car_id;

CREATE OR REPLACE VIEW `roxschool_cars.vw_calendar` AS
SELECT * FROM `roxschool_cars.dim_date`;
