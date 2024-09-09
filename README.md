# Documentação do Projeto: **DWComDBT**

## 1. Visão Geral do Projeto

Este projeto tem como objetivo a construção de um pipeline de dados para extração, carregamento e transformação (ETL) de informações sobre commodities (petróleo bruto, ouro e prata) utilizando a biblioteca `yfinance`. Os dados extraídos são armazenados em um banco de dados PostgreSQL, onde são processados e transformados utilizando `dbt` (data build tool) para gerar relatórios que permitem análises detalhadas de movimentações e tendências do mercado de commodities.

### Estrutura do Projeto:

- **Extração e Carregamento:** Coleta de dados financeiros históricos de commodities por meio da API `yfinance` e salvamento desses dados em uma tabela PostgreSQL.
- **Transformação com DBT:** Uso do dbt para limpar, transformar e integrar os dados de commodities e suas movimentações.
- **Análise:** Criação de datamarts e modelos agregados para análise de dados sobre as movimentações de commodities e cálculo de métricas importantes como ganhos ou perdas.

### Benefícios da Ferramenta DBT
A escolha do dbt como ferramenta de transformação de dados no projeto traz uma série de benefícios, que vão desde a organização e a facilidade de gerenciamento até a garantia de qualidade e consistência dos dados. A seguir, destacam-se os principais benefícios:

**1. Transformação de Dados SQL-Centric**

O dbt permite que você escreva transformações de dados diretamente em SQL, o que é altamente vantajoso para engenheiros e analistas de dados que estão familiarizados com essa linguagem. Ele facilita a construção de modelos de dados consistentes com base nas tabelas brutas.

**2. Reprodutibilidade e Versionamento**

Toda a lógica de transformação de dados é codificada em modelos SQL versionáveis, permitindo rastrear mudanças ao longo do tempo e garantir que o pipeline de dados seja reproduzível. Isso também contribui para a transparência e auditabilidade dos processos de ETL.

**3. Separação de Camadas de Dados (Staging, Datamarts)**

A estrutura do dbt incentiva a criação de camadas de dados intermediárias (como tabelas de staging) antes de chegar ao datamart final. Isso facilita o entendimento, a manutenção e o reuso de dados em diferentes partes do pipeline.

**4. Documentação Automática**

O dbt permite documentar cada modelo, tabela, e coluna diretamente no código. Isso facilita a criação de uma documentação rica, que pode ser gerada automaticamente e acessada através de uma interface web. Isso garante que os membros da equipe ou futuros desenvolvedores entendam os modelos de dados e sua origem.

**5. Testes Automáticos de Qualidade de Dados**

O dbt permite definir testes de integridade de dados de maneira simples, como checar a unicidade de chaves primárias, a presença de valores nulos ou a consistência de valores. Esses testes garantem que os dados estejam sempre em conformidade com as regras definidas, minimizando erros.

**6. Modularidade e Reutilização**

A possibilidade de utilizar macros permite escrever código SQL reutilizável, reduzindo a duplicação de código e melhorando a manutenibilidade. Também facilita o uso de transformações complexas e recorrentes em diversos modelos.

**7. Orquestração e Execução Fácil**

O dbt organiza a execução dos modelos de forma que as dependências sejam respeitadas, garantindo que os modelos de downstream sejam atualizados após a execução bem-sucedida dos upstream. Essa orquestração automática economiza tempo e esforço na gerência das dependências.

**8. Escalabilidade e Desempenho**

Como o dbt é executado diretamente no banco de dados, ele aproveita o desempenho do próprio mecanismo de SQL subjacente (neste caso, o PostgreSQL), permitindo que as transformações sejam escaláveis e eficientes, mesmo com grandes volumes de dados.

O dbt oferece uma poderosa combinação de simplicidade e robustez para a transformação de dados, permitindo a construção de pipelines eficientes, com rastreabilidade e alta qualidade. A modularidade e o foco na documentação e testes fazem do dbt uma ferramenta indispensável para equipes de dados que buscam padronizar e automatizar processos de transformação.

---

## 2. Arquivos do Projeto

# Estrutura de Pastas do Projeto

```bash
dwcomdbt/
│
├── dwcomdbt/
│   ├── dbt_project.yml            # Configurações do projeto dbt
│   ├── profiles.yml               # Perfis e conexões com o banco de dados
│   ├── models/
│   │   ├── staging/               # Modelos de staging (pré-transformação)
│   │   │   ├── stg_commodities.sql
│   │   │   ├── stg_movimentacao_commodities.sql
│   │   │   ├── schema.yml         # Esquema para o staging
│   │   ├── datamart/              # Modelos finais para análise
│   │   │   ├── dm_commodities.sql
│   │   │   ├── schema.yml         # Esquema para o datamart
│   ├── seeds/                     # Dados seed (pré-carregados para exemplos ou testes)
│   ├── tests/                     # Testes de qualidade de dados
│   ├── snapshots/                 # Snapshots para capturar mudanças de dados ao longo do tempo
│   ├── docs/                      # Documentação do projeto dbt
│   │   ├── homepage.md            # Página inicial de documentação
│   ├── macros/                    # Macros para reutilização de código SQL
│   ├── target/                    # Diretório de saída do dbt, com os artefatos criados
│
├── src/
│   ├── extract_load.py            # Script de extração e carregamento de dados para PostgreSQL
│   ├── requirements.txt           # Dependências do projeto
│
└── .env                           # Arquivo de variáveis de ambiente (não versionado)
```

## Arquivos `schema.yml` por Diretório

### 1. `models/staging/schema.yml`

Este arquivo define a documentação e os testes de dados para as tabelas de staging. Ele assegura que os dados extraídos e transformados para a camada intermediária estejam corretos.

```yaml
version: 2

models:
  - name: stg_commodities
    description: "Tabela de staging para dados de commodities"
    columns:
      - name: data
        description: "Data da observação no formato AAAA-MM-DD"
        tests:
          - not_null
      - name: valor_fechamento
        description: "Preço de fechamento da commodity com precisão decimal 4.2"
        tests:
          - not_null
      - name: simbolo
        description: "Símbolo da commodity"
        tests:
          - not_null

  - name: stg_movimentacao_commodities
    description: "Tabela de staging para dados de movimentação de commodities"
    columns:
      - name: data
        description: "Data da transação no formato AAAA-MM-DD"
        tests:
          - not_null
      - name: simbolo
        description: "Símbolo da commodity"
        tests:
          - not_null
      - name: acao
        description: "Tipo de transação (buy/sell)"
      - name: quantidade
        description: "Quantidade transacionada"
        tests:
          - not_null
```

### 2. `models/datamart/schema.yml`

Este arquivo descreve a estrutura da tabela final, que estará pronta para análise no datamart. Além disso, define os testes para garantir a integridade dos dados de saída.

```yaml
version: 2

models:
  - name: dm_commodities
    description: "Datamart para dados de commodities integrados com movimentações"
    columns:
      - name: data
        description: "Data da observação"
        tests:
          - not_null
      - name: simbolo
        description: "Símbolo da commodity"
        tests:
          - not_null
      - name: valor_fechamento
        description: "Preço de fechamento da commodity"
        tests:
          - not_null
      - name: acao
        description: "Tipo de transação (buy/sell)"
      - name: quantidade
        description: "Quantidade transacionada"
        tests:
          - not_null
      - name: valor
        description: "Valor da transação"
      - name: ganho
        description: "Ganho ou perda da transação"
```

## Benefícios do `schema.yml`

1. **Validação dos Dados**: A inclusão de testes como `not_null` e `unique` assegura que os dados críticos estejam sempre completos e corretos.
   
2. **Documentação Clara**: A documentação das tabelas e colunas garante que a equipe entenda a finalidade de cada dado, facilitando a manutenção e a colaboração.

3. **Automação**: Esses arquivos permitem que o `dbt` gere automaticamente documentação atualizada e execute testes de qualidade de dados, economizando tempo e prevenindo erros manuais.

---

### 2.1 Arquivo `profiles.yml`

Este arquivo configura o perfil do projeto dbt. Ele define o ambiente de execução e as credenciais para conectar ao banco de dados PostgreSQL em um ambiente de produção, utilizando variáveis de ambiente para proteger informações sensíveis.

```yaml
dwcomdbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DB_HOST_PROD') }}"
      user: "{{ env_var('DB_USER_PROD') }}"
      password: "{{ env_var('DB_PASS_PROD') }}"
      port: "{{ env_var('DB_PORT_PROD') | int }}"
      dbname: "{{ env_var('DB_NAME_PROD') }}"
      schema: "{{ env_var('DB_SCHEMA_PROD') }}"
      threads: "{{ env_var('DB_THREADS_PROD') | int }}"
      keepalives_idle: 0
```

### 2.2 Arquivo `requirements.txt`

O projeto utiliza as seguintes bibliotecas Python para facilitar a coleta de dados e comunicação com o banco de dados:

- `pandas`: Para manipulação de dados.
- `sqlalchemy`: Para conexão e interação com o PostgreSQL.
- `python-dotenv`: Para carregar variáveis de ambiente.
- `psycopg2-binary`: Para interação com o banco de dados PostgreSQL.
- `yfinance`: Para buscar os dados financeiros de commodities.

```bash
pandas
sqlalchemy
python-dotenv
psycopg2-binary
yfinance
```

### 2.3 Script `extract_load.py`

Este é o script de extração e carregamento de dados. Ele coleta informações históricas de commodities (Crude Oil, Gold e Silver) utilizando a biblioteca `yfinance` e carrega os dados no PostgreSQL.

#### Principais Componentes:

1. **Coleta de Dados:**
   - A função `buscar_dados_do_commodities` extrai os dados históricos de fechamento de preços das commodities, utilizando `yfinance`, e adiciona o símbolo da commodity.

2. **Transformação:**
   - Os dados coletados são concatenados e organizados em um DataFrame.

3. **Carregamento no PostgreSQL:**
   - A função `salvar_no_postgres` salva os dados no PostgreSQL, utilizando `SQLAlchemy`.

```python
def buscar_dados_do_commodities(simbolo, periodo='5y', intervalo='1d'):
    ticker = yf.Ticker(simbolo)
    dados = ticker.history(period=periodo, interval=intervalo)[['Close']]
    dados['simbolo'] = simbolo
    return dados
```

```python
def salvar_no_postgres(df, schema='public'):
    df.to_sql('commodities', engine, if_exists='replace', index=True, index_label='date', schema=schema)
```

### 2.4 Arquivo `dbt_project.yml`

Configura o projeto `dbt`, onde define caminhos para os diretórios dos modelos, testes, snapshots e análises. Também configura o nome do projeto e o perfil a ser utilizado.

```yaml
name: 'dwcomdbt'
version: '1.0.0'
profile: 'dwcomdbt'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
docs-paths: ["docs"]
```

---

## 3. Modelagem e Transformação de Dados com DBT

### 3.1 Models

Os modelos dbt são responsáveis por transformar os dados brutos extraídos para gerar tabelas que podem ser facilmente analisadas.

#### 3.1.1 `stg_commodities.sql`

Este modelo de *staging* transforma os dados brutos da tabela `commodities` em uma versão mais organizada, alterando os nomes das colunas para português e formatando as datas.

```sql
with source as (
    select
        "date",
        "Close",
        "simbolo"
    from 
        {{ source ('database_rq2i', 'commodities') }}
),
renamed as (
    select
        cast("date" as date) as data,
        "Close" as valor_fechamento,
        simbolo
    from
        source
)
select * from renamed
```

#### 3.1.2 `stg_movimentacao_commodities.sql`

Este modelo faz a mesma transformação para a tabela de movimentações de commodities, organizando os dados e facilitando a integração posterior.

```sql
with source as (
    select
        date,
        symbol,
        action,
        quantity
    from 
        {{ source('database_rq2i', 'movimentacao_commodities') }}
),
renamed as (
    select
        cast(date as date) as data,
        symbol as simbolo,
        action as acao,
        quantity as quantidade
    from source
)
select * from renamed
```

---

### 3.2 Datamart `dm_commodities`

O datamart final integra os dados de commodities e movimentações. Ele calcula o valor total das transações e o ganho ou perda baseado no preço de fechamento das commodities no momento da transação.

```sql
with commodities as (
    select
        data,
        simbolo,
        valor_fechamento
    from 
        {{ ref ('stg_commodities')  }}
),
movimentacao as (
    select
        data,
        simbolo,
        acao,
        quantidade
    from 
        {{ ref ('stg_movimentacao_commodities') }}
),
joined as (
    select
        c.data,
        c.simbolo,
        c.valor_fechamento,
        m.acao,
        m.quantidade,
        (m.quantidade * c.valor_fechamento) as valor,
        case
            when m.acao = 'sell' then (m.quantidade * c.valor_fechamento)
            else -(m.quantidade * c.valor_fechamento)
        end as ganho
    from
        commodities c
    inner join
        movimentacao m
    on
        c.data = m.data
        and c.simbolo = m.simbolo
)
select
    data,
    simbolo,
    valor_fechamento,
    acao,
    quantidade,
    valor,
    ganho
from
    joined
```
O `dbt` oferece uma variedade de comandos que ajudam a orquestrar, depurar, gerar e servir modelos de dados transformados. Abaixo está uma explicação detalhada sobre os comandos mais importantes do `dbt`, incluindo `dbt debug`, `dbt run`, `dbt docs generate` e `dbt docs serve`.

---

### 1. **`dbt debug`**
   O comando `dbt debug` é utilizado para verificar se a configuração do ambiente está correta e se o `dbt` está conseguindo se conectar ao banco de dados e a outros recursos configurados no projeto.

   #### O que ele faz:
   - Testa se o arquivo `profiles.yml` está configurado corretamente.
   - Verifica se as variáveis de ambiente, como as credenciais de banco de dados, estão acessíveis.
   - Tenta estabelecer uma conexão com o banco de dados para garantir que as informações fornecidas (host, porta, usuário, senha, etc.) sejam válidas.

   #### Quando usar:
   - Após configurar o projeto e definir o arquivo `profiles.yml`.
   - Quando surgir algum problema de conexão com o banco de dados.

   #### Exemplo de uso:
   ```bash
   dbt debug
   ```

   O comando retornará uma lista de verificações, onde você verá `PASSED` ou `FAILED` para cada etapa da conexão.

---

### 2. **`dbt run`**
   O comando `dbt run` executa as transformações de dados definidas nos modelos SQL dentro do projeto. Este é o comando mais central do `dbt`, pois é o responsável por construir as tabelas e views transformadas no banco de dados.

   #### O que ele faz:
   - Executa todos os modelos SQL dentro da pasta `models/`.
   - Respeita as dependências entre os modelos (execução em ordem correta).
   - Atualiza ou recria as tabelas/views de acordo com o tipo de materialização definido (`table`, `view`, ou `incremental`).

   #### Quando usar:
   - Sempre que houver uma alteração nos modelos SQL e for necessário atualizar os dados transformados no banco de dados.
   - Para automatizar as rotinas de ETL e carregar novos dados no datamart.

   #### Exemplo de uso:
   ```bash
   dbt run
   ```

   Este comando cria ou atualiza as tabelas e views no banco de dados conforme as transformações definidas no projeto.

---

### 3. **`dbt docs generate`**
   O comando `dbt docs generate` gera a documentação do projeto automaticamente a partir das descrições fornecidas nos arquivos `schema.yml`. Ele cria uma estrutura navegável em HTML, que contém informações detalhadas sobre as tabelas, colunas, e testes de qualidade de dados.

   #### O que ele faz:
   - Gera um conjunto de arquivos HTML que representam a documentação do projeto.
   - Inclui diagramas de dependência mostrando como os modelos interagem entre si.
   - Cria documentação com base nos metadados descritos no arquivo `schema.yml`, como descrições de tabelas e colunas, bem como os resultados dos testes de dados.

   #### Quando usar:
   - Após configurar ou alterar as descrições nos arquivos `schema.yml`.
   - Quando for necessário gerar a documentação atualizada do pipeline de dados para compartilhamento com a equipe.

   #### Exemplo de uso:
   ```bash
   dbt docs generate
   ```

   Esse comando cria um diretório `target/` contendo os arquivos HTML da documentação, prontos para visualização.

---

### 4. **`dbt docs serve`**
   O comando `dbt docs serve` abre um servidor web local para você visualizar a documentação gerada pelo comando `dbt docs generate`. Ele facilita a navegação pelos modelos e diagramas de dependência diretamente no navegador.

   #### O que ele faz:
   - Inicia um servidor web local que permite a navegação pela documentação do projeto.
   - Facilita a visualização interativa dos modelos, suas descrições e testes de qualidade.
   - Inclui uma visualização gráfica dos relacionamentos entre os modelos, o que ajuda na compreensão das dependências.

   #### Quando usar:
   - Para compartilhar a documentação gerada com a equipe de dados.
   - Quando for necessário revisar a estrutura de dados e os relacionamentos entre modelos.
   - Quando precisar entender as transformações de dados em um formato visual.

   #### Exemplo de uso:
   ```bash
   dbt docs serve
   ```

   O comando iniciará um servidor local (geralmente acessível em `http://localhost:8080`) onde você poderá navegar pela documentação gerada.

---

## Exemplos de Comandos Combinados no Fluxo de Trabalho

1. **Conexão e Diagnóstico**:
   - Antes de rodar qualquer transformação, você pode verificar se o ambiente está configurado corretamente com o comando:
     ```bash
     dbt debug
     ```

2. **Execução de Transformações**:
   - Após garantir que a configuração está correta, execute os modelos com:
     ```bash
     dbt run
     ```

3. **Geração e Visualização de Documentação**:
   - Para gerar e visualizar a documentação, você pode usar:
     ```bash
     dbt docs generate
     dbt docs serve
     ```
---

Esses comandos do `dbt` são essenciais para gerenciar pipelines de dados de maneira organizada, eficiente e facilmente auditável. O `dbt` ajuda a transformar dados brutos em insights acionáveis, automatizando grande parte do trabalho e facilitando a colaboração entre equipes. A capacidade de documentar e testar dados automaticamente também contribui para a robustez e confiabilidade das soluções desenvolvidas.

---

### Lineage Graph

![image](https://github.com/user-attachments/assets/d39254a6-5861-4240-92a3-33b27bd58f3e)

O **lineage graph** no `dbt` é uma representação visual das dependências entre os modelos de dados do projeto. Ele mostra como os dados fluem através das diferentes transformações, desde as tabelas brutas (sources) até os modelos finais no datamart.

## Principais características:

- **Fluxo de dados**: Exibe a sequência de transformações dos dados, conectando fontes, tabelas intermediárias e tabelas finais.
- **Dependências entre modelos**: Mostra como um modelo depende de outros, facilitando a compreensão do impacto de mudanças nos dados.
- **Visão hierárquica**: Ajuda a identificar relações de upstream (entrada) e downstream (saída), útil para entender o contexto geral do pipeline de dados.

O lineage graph é útil para documentar o processo de ETL e garantir a clareza e transparência das transformações aplicadas aos dados.

---

## 4. Conclusão

Este projeto implementa um pipeline completo de ETL, utilizando bibliotecas e ferramentas populares para a coleta, processamento e análise de dados. O dbt desempenha um papel fundamental na transformação dos dados, enquanto o PostgreSQL serve como o armazém centralizado para análise. Ao final, os dados processados estão prontos para serem consumidos por dashboards e relatórios, permitindo insights acionáveis sobre o mercado de commodities.
