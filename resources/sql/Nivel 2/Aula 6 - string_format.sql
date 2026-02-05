-- ============================================================
-- ROX SCHOOL | BigQuery SQL
-- Tema: FUNÇÕES DE TEXTO, FORMATAÇÃO E PRECISÃO NUMÉRICA
--
-- Objetivo:
--   Demonstrar técnicas de limpeza, padronização, formatação
--   e cálculo com strings e números no BigQuery.
-- ============================================================

-- ============================================================
-- AULA 1 | PADRONIZAÇÃO E LIMPEZA DE TEXTO
-- ============================================================

-- 1) Padronização de caixa, contagem e limpeza de strings
--    Essencial para JOINs, exibição em dashboards e validações
SELECT
  nome_original,

  -- UPPER / LOWER: padronização de caixa
  UPPER(nome_original) AS nome_maiusculo,
  LOWER(nome_original) AS nome_minusculo,

  -- INITCAP: primeira letra de cada palavra em maiúscula
  INITCAP(nome_original) AS nome_formatado,

  -- LENGTH: contagem de caracteres
  LENGTH(nome_original) AS total_caracteres,

  -- TRIM: remove espaços no início e no fim
  TRIM(nome_original) AS texto_sem_espacos_nas_pontas,

  -- REVERSE: inverte a string
  REVERSE(nome_original) AS nome_invertido
FROM (
  SELECT '  joão dA silva  ' AS nome_original UNION ALL
  SELECT 'maria ferreira'   AS nome_original
);

-- ============================================================
-- AULA 2 | EXTRAÇÃO E MODIFICAÇÃO DE TEXTO
-- ============================================================

-- 2) SUBSTR, REPLACE, STRPOS, LEFT e RIGHT
--    Técnicas para corte, substituição e inspeção de strings
SELECT
  -- SUBSTR: extrai parte do texto (prefixo)
  SUBSTR('PROD12345', 1, 4) AS prefixo_produto,

  -- REPLACE: substituição de caracteres
  REPLACE('R$ 1.500,00', ',', '.') AS valor_americano,

  -- STRPOS: posição de um caractere
  STRPOS('aluno_google@gmail.com', '@') AS posicao_arroba,

  -- LEFT / RIGHT: caracteres das extremidades
  LEFT('São Paulo-SP', 3)  AS tres_primeiras,
  RIGHT('São Paulo-SP', 2) AS uf
FROM (SELECT 1);

-- ============================================================
-- AULA 3 | CONCATENAÇÃO, ARRAYS E PREENCHIMENTO
-- ============================================================

-- 3) CONCAT, operador ||, LPAD, SPLIT e REPEAT
--    Muito usados para códigos, identificadores e rótulos
SELECT
  -- CONCAT: junção de textos
  CONCAT('ID', '-', '995') AS id_com_prefixo,

  -- Operador ||: concatenação alternativa
  'Usuário: ' || 'Carlos' AS saudacao,

  -- LPAD: preenchimento com zeros à esquerda
  LPAD('452', 6, '0') AS id_formatado, -- 000452

  -- SPLIT: transforma texto em ARRAY
  SPLIT('Maçã,Banana,Laranja', ',') AS lista_frutas,

  -- REPEAT: repetição de caracteres
  REPEAT('*', 5) AS avaliacao_estrelas
FROM (SELECT 1);

-- ============================================================
-- AULA 4 | ARREDONDAMENTO E PRECISÃO NUMÉRICA
-- ============================================================

-- 4) ROUND, TRUNC, CEIL e FLOOR
--    Base para cálculos financeiros e estatísticos
SELECT
  valor_bruto,

  -- ROUND: arredondamento tradicional
  ROUND(valor_bruto, 2) AS arredondado_2_casas,

  -- TRUNC: corte sem arredondar
  TRUNC(valor_bruto, 1) AS truncado_1_casa,

  -- CEIL: arredonda para cima
  CEIL(valor_bruto) AS proximo_inteiro_cima,

  -- FLOOR: arredonda para baixo
  FLOOR(valor_bruto) AS proximo_inteiro_baixo
FROM (SELECT 15.8765 AS valor_bruto);

-- ============================================================
-- AULA 5 | FORMATAÇÃO PARA RELATÓRIOS
-- ============================================================

-- 5) FORMAT: moedas, milhares e notação científica
SELECT
  faturamento,

  -- Separador de milhar + prefixo de moeda
  'R$ ' || FORMAT("%'d", CAST(faturamento AS INT64)) AS faturamento_formatado_milhar,

  -- Casas decimais fixas
  FORMAT('%.2f', faturamento) AS faturamento_duas_casas,

  -- Notação científica
  FORMAT('%e', faturamento) AS notacao_cientifica
FROM (SELECT 1250500.89 AS faturamento);

-- ============================================================
-- AULA 6 | PORCENTAGEM E DIVISÃO "SEGURA" SAFE_DIVIDE
-- ============================================================

-- 6) SAFE_DIVIDE: cálculo de variação percentual
--    Evita erro de divisão por zero
SELECT
  vendas_atual,
  vendas_anterior,

  ROUND(
    (SAFE_DIVIDE(vendas_atual, vendas_anterior) - 1) * 100,
    2
  ) || '%' AS crescimento_percentual
FROM (SELECT 150 AS vendas_atual, 100 AS vendas_anterior);

-- ============================================================
-- AULA 7 | FUNÇÕES DE VERIFICAÇÃO E SINAIS
-- ============================================================

-- 7) ABS, SIGN e MOD
--    Muito usadas em regras de negócio e lógica condicional
SELECT
  numero,

  -- ABS: valor absoluto
  ABS(numero) AS valor_absoluto,

  -- SIGN: identifica o sinal do número
  SIGN(numero) AS sinal_do_numero,

  -- MOD: resto da divisão (par ou ímpar)
  MOD(CAST(ABS(numero) AS INT64), 2) AS resto_divisao_por_2
FROM (SELECT -42 AS numero);

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
