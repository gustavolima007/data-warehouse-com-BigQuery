-- ============================================================
-- ROX SCHOOL | BigQuery SQL
-- Tema: FUNÇÕES DE DATA E HORA (DATE / DATETIME / TIMESTAMP)
--
-- Objetivo:
--   Demonstrar extração de partes da data, formatação,
--   aritmética com datas, diferenças, parsing e funções úteis
--   para relatórios e análises temporais.
--
-- Observações:
--   - current_date e current_timestamp dependem do timezone da sessão.
--   - TIMESTAMP é sempre um instante absoluto (UTC); DATETIME não tem fuso.
-- ============================================================

-- ============================================================
-- AULA 1 | EXTRACT: PARTES DA DATA (ANO, MÊS, DIA, TRIMESTRE)
-- ============================================================

-- 1) Extraindo componentes da data atual
SELECT
  CURRENT_DATE() AS data_hoje,
  EXTRACT(YEAR FROM CURRENT_DATE()) AS ano,
  EXTRACT(MONTH FROM CURRENT_DATE()) AS mes,
  EXTRACT(DAY FROM CURRENT_DATE()) AS dia,
  EXTRACT(DAYOFWEEK FROM CURRENT_DATE()) AS dia_da_semana, -- 1 (Domingo) a 7 (Sábado)
  EXTRACT(QUARTER FROM CURRENT_DATE()) AS trimestre;

-- ============================================================
-- AULA 2 | FORMAT_DATE: FORMATAÇÃO PARA RELATÓRIOS
-- ============================================================

-- 2) Formatando uma data em diferentes padrões (BR, ano-mês, nome do dia)
SELECT
  data_original,
  FORMAT_DATE('%d/%m/%Y', data_original) AS formato_br,
  FORMAT_DATE('%Y-%m', data_original) AS ano_mes,
  FORMAT_DATE('%A', data_original) AS nome_dia_semana
FROM (SELECT DATE('2026-01-06') AS data_original);

-- ============================================================
-- AULA 3 | ARITMÉTICA COM DATAS (ADD / SUB / TRUNC)
-- ============================================================

-- 3) Somando e subtraindo intervalos e truncando para início do mês
SELECT
  CURRENT_DATE() AS hoje,
  DATE_ADD(CURRENT_DATE(), INTERVAL 15 DAY) AS daqui_a_15_dias,
  DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH) AS um_mes_atras,
  DATE_TRUNC(CURRENT_DATE(), MONTH) AS primeiro_dia_do_mes_atual;

-- ============================================================
-- AULA 4 | DATE_DIFF: DIFERENÇA ENTRE DATAS
-- ============================================================

-- 4) Diferença em dias e diferença aproximada em anos (idade)
SELECT
  DATE_DIFF(DATE '2026-12-31', DATE '2026-01-06', DAY) AS dias_para_fim_do_ano,
  DATE_DIFF(CURRENT_DATE(), DATE '1995-05-15', YEAR) AS idade_aproximada;

-- ============================================================
-- AULA 5 | TIMESTAMP, DATETIME E TIMEZONE
-- ============================================================

-- 5) Pegando timestamp atual e convertendo para horário de Brasília
--    TIMESTAMP é um instante em UTC; DATETIME representa data/hora sem fuso
SELECT
  CURRENT_TIMESTAMP() AS tempo_utc,
  DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo") AS horario_brasilia,
  FORMAT_DATETIME(
    '%d/%m/%Y %H:%M:%S',
    DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo")
  ) AS brasilia_formatado;

-- ============================================================
-- AULA 6 | PARSE_DATE / PARSE_TIMESTAMP: CONVERSÃO DE TEXTO
-- ============================================================

-- 6) Convertendo strings para DATE e TIMESTAMP
SELECT
  PARSE_DATE('%d/%m/%Y', '25/12/2025') AS data_convertida,
  PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', '2025-10-30 14:30:00') AS timestamp_convertido;

-- ============================================================
-- AULA 7 | LAST_DAY: ÚLTIMO DIA DO MÊS / ANO
-- ============================================================

-- 7) Último dia do mês atual e do ano atual
SELECT
  LAST_DAY(CURRENT_DATE(), MONTH) AS ultimo_dia_deste_mes,
  LAST_DAY(CURRENT_DATE(), YEAR) AS ultimo_dia_do_ano;

-- ============================================================
-- EXTRA | DESAFIO: DIAS ATÉ UMA DATA (ANIVERSÁRIO)
-- ============================================================

-- 8) Quantos dias faltam para uma data alvo?
--    Troque DATE '2025-01-01' pela sua data (no ano desejado) e teste.
SELECT
  DATE_DIFF(DATE '2025-01-01', CURRENT_DATE(), DAY) AS dias_faltantes,
  FORMAT_DATE('%A', DATE '2025-01-01') AS dia_da_semana;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
