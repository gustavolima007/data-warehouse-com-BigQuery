# Trilha Data Warehouse com BigQuery — Nível 1

Este repositório guarda o material do primeiro curso da trilha **Data Warehouse com BigQuery**. Aqui você encontra os fundamentos de Big Data, criação do projeto no Google Cloud, primeiros passos em SQL e práticas guiadas. Todo o conteúdo foi organizado para que seja simples expandir para os módulos intermediário e avançado.

## Nível 2 (resumo)

Panorama do conteúdo intermediário e avançado previsto para a trilha, cobrindo funções SQL avançadas, otimização de consultas e fundamentos de Machine Learning aplicados ao BigQuery ML.

| Módulo | Tema | Resumo |
| --- | --- | --- |
| 01 | Funções SQL Avançadas | Window functions, funções de valor/aggregate, geoespaciais, formatação, datas e regex |
| 02 | Otimização de Consultas | Estratégias de performance, clusterização, particionamento, boas práticas e plano de execução |
| 03 | Fundamentos de Machine Learning | Conceitos, tipos de aprendizado, algoritmos e métricas principais |
| 04 | Introdução ao BigQuery ML | Conceitos, modelos suportados, criação, avaliação e inferência |
| 05 | Modelos com BigQuery ML | Classificação, regressão, séries temporais e clusterização com avaliação |
| 06 | Prática Guiada | Casos práticos de vendas, crédito, segmentação e recomendação |
| 07 | Encerramento | Revisão e próximos passos |

## Objetivos

- Entender o papel do BigQuery dentro de um ecossistema de Data Warehouse.
- Montar um ambiente de estudo com datasets de apoio e scripts reutilizáveis.
- Executar consultas básicas e intermediárias (DQL, DML, DDL) com boas práticas de performance.
- Criar uma base sólida para módulos futuros (modelagem dimensional, otimizações e orquestração).

## Pré-requisitos recomendados

1. Conta Google Cloud com acesso ao BigQuery (um projeto de testes é suficiente).
2. Git configurado localmente para clonar o repositório.
3. Editor de SQL / VS Code ou Cloud Shell Editor.
4. (Opcional) Python/Notebooks se desejar replicar análises em `resources/notebooks/`.

## Estrutura

```
.
├── modules/                # 10 módulos introdutórios (um diretório por tema)
├── resources/
│   ├── data/               # Datasets CSV/JSON usados nos exercícios
│   ├── sql/                # Scripts comentados para cada aula
│   ├── notebooks/          # Notebooks auxiliares
│   ├── notes/              # Anotações e resumos por módulo
│   └── checklists/         # Planos de estudo e revisões
└── docs/ (planejado)       # Guias extras para futuras trilhas
```

## Como usar

1. Clone o repositório e abra o módulo desejado em `modules/`.
2. Leia o README do módulo para contexto, objetivos e exercícios daquela etapa.
3. Carregue os datasets necessários conforme descrito em `resources/README.md`.
4. Execute os scripts SQL em `resources/sql/` na sequência indicada, adaptando para o seu projeto.
5. Registre aprendizados em `resources/notes/` e marque os itens das checklists.

## Mapa dos módulos

| Módulo | Tema | Resultado esperado |
| --- | --- | --- |
| 01 | Introdução ao Big Data | Diferenciar DW, Data Lake e Lakehouse |
| 02 | O que é BigQuery | Entender arquitetura e casos de uso |
| 03 | Criação do projeto GCP | Criar projeto, billing e dataset inicial |
| 04 | Conjuntos e Tabelas | Operar datasets/tabelas no console e CLI |
| 05 | Ingestão e Integração | Testar cargas por UI, CLI e arquivos |
| 06 | Introdução ao SQL | Revisar DQL básico com exemplos práticos |
| 07 | Filtragem e Ordenação | Aplicar WHERE, ORDER BY, LIMIT |
| 08 | Agrupamento e Junção | Trabalhar com GROUP BY, HAVING e JOINs |
| 09 | Visualizações e Painéis | Exportar resultados para BI / Looker |
| 10 | Prática guiada | Consolidar aprendizados em estudo de caso |
