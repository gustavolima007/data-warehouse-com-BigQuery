# Data Warehouse com BigQuery — Roadmap de Módulos

Este diretório concentra apenas a visão geral dos módulos planejados para o treinamento. Todo o conteúdo detalhado (slides, scripts SQL, exercícios e laboratórios) deve ficar em `resources/` ou em repositórios específicos por módulo, mantendo este espaço simples e navegável.

## Visão Geral

| Módulo | Tema | Objetivo |
| --- | --- | --- |
| 01 | Introdução ao Big Data | Conceituar Data Warehousing moderno, casos de uso e principais componentes GCP. |
| 02 | BigQuery Fundamentals | Apresentar arquitetura, separação storage/compute e principais recursos gerenciados. |
| 03 | Preparação do Projeto GCP | Criar projeto, configurar billing, APIs necessárias e políticas básicas (IAM/quotas). |
| 04 | Modelagem de Conjuntos e Tabelas | Cobrir datasets, tabelas particionadas/clusterizadas e padrões de nomenclatura. |
| 05 | Ingestão e Integração | Demonstrar ingestão via Dataflow, Pub/Sub, Storage e carregamentos manuais. |
| 06 | SQL Essentials | Revisar SQL padrão ANSI com extensões BigQuery e boas práticas de otimização. |
| 07 | Filtragem e Ordenação | Explorar WHERE, QUALIFY, ORDER BY, LIMIT e estratégias de custo. |
| 08 | Agregações e Junções | Trabalhar funções analíticas, GROUP BY, HAVING, JOINs e uso de CTEs. |
| 09 | Visualizações e Painéis | Integrar com Looker Studio, Connected Sheets e Data Catalog para governança. |
| 10 | Laboratório Orientado | Consolidar aprendizados em um caso end-to-end com dados sintéticos. |

## Estrutura Recomendada

```
modules/
  README.md          -> Este arquivo (roadmap e convenções)
resources/
  <module>/          -> Scripts SQL, notebooks, diagramas e dados de apoio
```