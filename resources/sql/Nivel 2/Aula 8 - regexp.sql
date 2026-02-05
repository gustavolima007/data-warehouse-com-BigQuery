-- ============================================================
-- ROX SCHOOL | BigQuery SQL
-- Tema: EXPRESSÕES REGULARES (REGEXP)
--
-- Objetivo:
--   Demonstrar validação, extração, limpeza e filtros
--   avançados usando REGEXP no BigQuery.
-- ============================================================

-- ============================================================
-- AULA 1 | REGEXP_CONTAINS (VALIDAÇÃO BOOLEANA)
-- ============================================================

-- 1) REGEXP_CONTAINS: verifica se o padrão existe na string
--    Muito usado em WHERE para validações simples
SELECT
  email,
  REGEXP_CONTAINS(
    email,
    r'@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
  ) AS email_valido
FROM (
  SELECT 'aluno@gmail.com'     AS email UNION ALL
  SELECT 'email_errado.com'    AS email
);

-- ============================================================
-- AULA 2 | REGEXP_EXTRACT (EXTRAÇÃO SIMPLES)
-- ============================================================

-- 2) REGEXP_EXTRACT: extrai a primeira ocorrência
--    Exemplo clássico: domínio de uma URL
SELECT
  url,
  REGEXP_EXTRACT(
    url,
    r'https?://([^/]+)'
  ) AS dominio
FROM (
  SELECT 'https://cloud.google.com/bigquery' AS url UNION ALL
  SELECT 'http://meusite.com.br/blog'         AS url
);

-- ============================================================
-- AULA 3 | REGEXP_EXTRACT_ALL (EXTRAÇÃO MÚLTIPLA)
-- ============================================================

-- 3) REGEXP_EXTRACT_ALL: retorna todas as ocorrências
--    Resultado é um ARRAY
SELECT
  texto,
  REGEXP_EXTRACT_ALL(
    texto,
    r'\d+'
  ) AS numeros_encontrados
FROM (
  SELECT 'O pedido 123 foi feito em 25/12 e custou 500 reais' AS texto
);

-- ============================================================
-- AULA 4 | REGEXP_REPLACE (LIMPEZA DE DADOS)
-- ============================================================

-- 4) REGEXP_REPLACE: substitui padrões por outro valor
--    Exemplo: limpar CPF mantendo apenas números
SELECT
  cpf_sujo,
  REGEXP_REPLACE(
    cpf_sujo,
    r'[\.\-]',
    ''
  ) AS cpf_limpo
FROM (
  SELECT '123.456.789-00' AS cpf_sujo
);

-- ============================================================
-- AULA 5 | REGEXP_INSTR (POSIÇÃO DO PADRÃO)
-- ============================================================

-- 5) REGEXP_INSTR: retorna a posição onde o padrão começa
--    Útil para inspeção e validação de strings
SELECT
  REGEXP_INSTR(
    'Produto_ID_99',
    r'[^a-zA-Z0-9]'
  ) AS posicao_caractere_especial;

-- ============================================================
-- AULA 6 | GRUPOS DE CAPTURA E BACK-REFERENCES
-- ============================================================

-- 6) Uso de grupos de captura para reorganizar textos
--    Exemplo: "Nome, Sobrenome" → "Sobrenome Nome"
SELECT
  nome_completo,
  REGEXP_REPLACE(
    nome_completo,
    r'([^,]+), (.+)',
    r'\2 \1'
  ) AS nome_formatado
FROM (
  SELECT 'Silva, Maria' AS nome_completo
);

-- ============================================================
-- AULA 7 | REGEXP CASE-INSENSITIVE
-- ============================================================

-- 7) Flag (?i): ignora maiúsculas e minúsculas
SELECT
  texto
FROM (
  SELECT 'O BIGQUERY é rápido' AS texto UNION ALL
  SELECT 'O bigquery é top'    AS texto
)
WHERE REGEXP_CONTAINS(
  texto,
  r'(?i)bigquery'
);

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
