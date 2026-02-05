-- ============================================================
-- ROX SCHOOL | BigQuery SQL
-- Tema: FUNÇÕES GEOSPACIAIS (GEOGRAPHY)
--
-- Objetivo:
--   Trabalhar com pontos, distâncias, proximidade (raio),
--   interseções e análises ponto-em-polígono usando GEOGRAPHY.
--
-- Bases (BigQuery Public Datasets):
--   - bigquery-public-data.geo_us_boundaries.zip_codes
--   - bigquery-public-data.new_york_citibike.citibike_stations
--
-- Observações:
--   - O BigQuery usa geometria esférica (WGS84) para GEOGRAPHY.
--   - É possível trabalhar com WKT (Well-Known Text) quando necessário.
-- ============================================================

-- ============================================================
-- AULA 1 | PONTOS E DISTÂNCIAS (ST_GEOGPOINT + ST_DISTANCE)
-- ============================================================

-- 1) Distância entre dois marcos de NYC (em metros e km)
--    Conceito: ST_GEOGPOINT(longitude, latitude) e ST_DISTANCE(p1, p2)
SELECT
  ST_DISTANCE(
    ST_GEOGPOINT(-73.9857, 40.7484), -- Empire State Building
    ST_GEOGPOINT(-73.9192, 40.7010)  -- Barclays Center
  ) AS distancia_metros,

  ST_DISTANCE(
    ST_GEOGPOINT(-73.9857, 40.7484),
    ST_GEOGPOINT(-73.9192, 40.7010)
  ) / 1000 AS distancia_km;

-- ============================================================
-- AULA 2 | PONTO DENTRO DE POLÍGONO (ST_CONTAINS)
-- ============================================================

-- 2) Identificar em qual ZIP Code uma coordenada cai (Times Square)
--    Conceito: polígono contém ponto
SELECT
  zip_code,
  city,
  state_code
FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
WHERE ST_CONTAINS(
  zip_code_geom,
  ST_GEOGPOINT(-73.9851, 40.7589) -- Times Square
);

-- ============================================================
-- AULA 3 | PROXIMIDADE / RAIO (ST_DWITHIN)
-- ============================================================

-- 3) Estações do Citi Bike em um raio de 500m de um ponto turístico
--    Conceito: ST_DWITHIN(ponto, ponto_referencia, raio_em_metros)
SELECT
  name,
  capacity,
  ST_DISTANCE(
    ST_GEOGPOINT(longitude, latitude),
    ST_GEOGPOINT(-73.981961, 40.768071) -- Columbus Circle
  ) AS distancia_metros
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
WHERE ST_DWITHIN(
  ST_GEOGPOINT(longitude, latitude),
  ST_GEOGPOINT(-73.981961, 40.768071),
  500
)
ORDER BY distancia_metros;

-- ============================================================
-- AULA 4 | AGREGAÇÃO PONTO-EM-POLÍGONO (DENSIDADE POR ÁREA)
-- ============================================================

-- 4) Contar quantas estações existem em cada ZIP Code de New York, NY
--    Conceito: join espacial (pontos -> polígonos) com ST_CONTAINS
SELECT
  zip.zip_code,
  zip.city,
  COUNT(*) AS total_estacoes
FROM `bigquery-public-data.new_york_citibike.citibike_stations` AS stations
JOIN `bigquery-public-data.geo_us_boundaries.zip_codes` AS zip
ON ST_CONTAINS(
  zip.zip_code_geom,
  ST_GEOGPOINT(stations.longitude, stations.latitude)
)
WHERE
  zip.state_code = 'NY'
  AND zip.city = 'New York'
GROUP BY 1, 2
ORDER BY total_estacoes DESC;

-- ============================================================
-- EXTRA | DESAFIO (MAX DISTANCE) + LINHAS (ST_MAKELINE)
-- ============================================================

-- 5) Desafio: qual estação fica mais distante da Times Square?
SELECT
  name,
  ST_DISTANCE(
    ST_GEOGPOINT(longitude, latitude),
    ST_GEOGPOINT(-73.9851, 40.7589) -- Times Square
  ) / 1000 AS km_distancia
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
ORDER BY km_distancia DESC
LIMIT 1;

-- 6) Criar uma linha (rota) entre a estação e a Times Square
--    Exemplo: apenas estações em até 2km (para visualização e debugging)
SELECT
  name,
  ST_MAKELINE(
    ST_GEOGPOINT(longitude, latitude),
    ST_GEOGPOINT(-73.9851, 40.7589)
  ) AS rota_geografica
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
WHERE ST_DWITHIN(
  ST_GEOGPOINT(longitude, latitude),
  ST_GEOGPOINT(-73.9851, 40.7589),
  2000
);

-- ============================================================
-- EXTRA | RECORTE ESPACIAL (ST_INTERSECTSBOX)
-- ============================================================

-- 7) Filtrar ZIPs por bounding box (retângulo) aproximado de NYC
--    Conceito: recorte rápido por caixa para reduzir volume de dados
SELECT
  zip_code,
  zip_code_geom
FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
WHERE ST_INTERSECTSBOX(
  zip_code_geom,
  -74.3, 40.5,  -- canto inferior esquerdo (lon, lat)
  -73.7, 40.9   -- canto superior direito  (lon, lat)
);

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
