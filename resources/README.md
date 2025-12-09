# Recursos

Este diretório reúne todos os artefatos de apoio usados nas aulas:

- `data/`: datasets CSV/JSON para ingestão no BigQuery. Inclui coleções públicas (BoardGameGeek, veículo etc.). Sempre confira política de uso:
  - `boardgame-geek-dataset_organized.csv`, `boardgamegeek.json`, `boardgames_corrijido.json`: dataset público da comunidade BoardGameGeek (Creative Commons BY-SA). Utilize apenas para fins educacionais.
  - `vehicle_price_prediction_vehicle_price_prediction.csv`: dataset de preços de veículos disponível em repositórios públicos de Machine Learning; recomendo importar apenas colunas necessárias para reduzir custos de armazenamento.
- `sql/`: scripts comentados por aula (22–38). Todos usam o projeto `bigquery-iniciante-roxschool` como exemplo; substitua para o seu projeto/dataset antes de executar.
- `notebooks/`: espaço para notebooks de análise exploratória (adicione conforme necessário).
- `notes/`, `checklists/`: anotações e planos de estudo por módulo.

## Como carregar os dados

1. Faça upload dos arquivos CSV/JSON para um bucket temporário ou use o upload direto no console BigQuery.
2. Crie datasets dedicados (ex.: `roxschool_cars`, `boardgames`) no seu projeto.
3. Execute as instruções DDL nos scripts correspondentes (por exemplo, `resources/sql/Aula 24 - ddl_roxschool_cars.sql`) para montar as tabelas.
4. Carregue os dados via UI, CLI (`bq load`) ou scripts mencionados nos módulos.

## Boas práticas

- Use `git lfs` para arquivos maiores que 50 MB se continuar versionando datasets (ex.: `vehicle_price_prediction_vehicle_price_prediction.csv` ~120 MB).
- Documente a origem/licença de novos datasets neste arquivo.
- Quando modificar scripts SQL, descreva rapidamente o objetivo e dependências no cabeçalho do arquivo (sem alterar os já existentes).
