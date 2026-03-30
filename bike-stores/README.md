# 🚲 Análise de Vendas — Bike Stores

Projeto de análise de dados utilizando o banco de dados **Bike Stores**, com foco em vendas, receita e comportamento comercial. Toda a análise foi realizada em **SQL Server**, com queries organizadas e documentadas.

---

## 🛠️ Ferramentas Utilizadas

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-CC2927?style=for-the-badge&logo=microsoft&logoColor=white)

---

## 📁 Arquivos

| Arquivo | Descrição |
|--------|-----------|
| `analise_vendas.sql` | Queries de verificação de qualidade e análise de vendas |

---

## 📋 Etapa 1 — Verificação de Qualidade dos Dados

Antes de começar qualquer análise, verifiquei a qualidade dos dados do banco — uma etapa essencial para garantir que os resultados sejam confiáveis.

Durante essa verificação, encontrei um problema: alguns pedidos tinham a data de envio registrada antes da data em que o pedido foi feito, o que é impossível na prática. Ao investigar, percebi que todos esses casos tinham algo em comum: a data do pedido era sempre 31 de dezembro. Isso indica que o sistema preencheu essa data automaticamente como um valor padrão quando a informação real não estava disponível — ou seja, não reflete uma compra real.

Para não comprometer as análises, esses registros foram descartados. Todos os números apresentados aqui consideram apenas pedidos com dados consistentes.

### O que foi verificado
- Valores nulos nas colunas críticas (`OrderID`, `CustomerID`, `OrderDate`, `Status`)
- Duplicatas na tabela de pedidos
- Preços e descontos fora do intervalo esperado (≤ 0 ou > 1)
- Datas de envio anteriores à data do pedido
- Estoque negativo

### O que foi encontrado
- Pedidos com `OrderDate = 31/12` apresentavam `ShippedDate` anterior à `OrderDate`, caracterizando um valor default de sistema.
- Demais verificações não apresentaram inconsistências.

### Decisão tomada
- Registros com `OrderDate = 31/12` foram excluídos de todas as análises por representarem datas não confiáveis.
- Criada a view `Sales.Orders_Clean` para centralizar esse filtro e garantir consistência em todas as queries.

---

## 📊 Etapa 2 — Análise de Vendas

### 2.1 Receita Total por Ano e Mês

A análise da receita mensal revelou uma tendência clara de queda ao longo dos anos. O ano de 2009 concentrou os maiores volumes de receita, com destaque para março, que registrou o maior valor do período analisado. A partir de 2010 a receita cai consideravelmente, e 2011 apresenta os menores valores — chegando a menos de um terço do pico de 2009.

Esse padrão pode indicar perda de mercado, redução no catálogo de produtos ou mudança no perfil de clientes ao longo do tempo — hipóteses que serão investigadas na etapa de visualização.

---

### 2.2 Top 10 Produtos por Receita e por Volume

Ao comparar os rankings por receita e por unidades vendidas, dois perfis distintos emergem. Produtos da marca **Trek** lideram em receita, com o Trek Slash 8 27.5 gerando mais de R$ 63M, enquanto produtos **Electra** dominam o volume de vendas — a Electra Townie Original 7D EQ vendeu mais de 34 mil unidades. Isso indica uma base de clientes diversa: compradores de alto valor e compradores de volume. Os produtos Trek Slash 8 e Surly Straggler se destacam por aparecerem em ambos os rankings.

---

### 2.3 Receita por Loja e Categoria

As três lojas — Baldwin Bikes, Rowlett Bikes e Santa Cruz Bikes — seguem um padrão consistente: **Mountain Bikes** é a categoria mais lucrativa em todas elas, seguida de Road Bicycles e Cruisers Bicycles. Não há especialização por loja — o mix de categorias é similar entre todas. O principal diferencial é o volume: **Baldwin Bikes** representa a maior fatia da receita total, enquanto **Rowlett Bikes** registra os menores números em todas as categorias.

---

### 2.4 Ticket Médio por Pedido

O ticket médio geral do período foi de **R$ 7.386,47**, refletindo o perfil de produto de alto valor da loja. Ao analisar por loja e ano, o comportamento é similar entre as três unidades — nenhuma se destaca consistentemente. O período de 2016-2017 registrou os menores tickets médios nas três lojas, coincidindo com a queda de receita já identificada. Em 2019 o ticket médio sobe expressivamente em todas as lojas, especialmente em Rowlett Bikes — porém com volume de pedidos menor, o que pode indicar maior variação nos dados. Baldwin Bikes, com 474 pedidos em 2019, confirma que o aumento de ticket nessa loja é representativo.

---

### 2.5 Crescimento Mês a Mês (MoM)

A análise de crescimento mensal revelou um padrão sazonal consistente: as maiores quedas ocorrem nas viradas de ano, com janeiro registrando recuos de até **-39%** em 2011. Por outro lado, agosto apresenta recuperações expressivas nos três anos analisados. O mês de março de 2011 registrou o maior crescimento do período (+39%), porém partindo de uma base já menor. Esse comportamento sazonal é um indicativo importante para planejamento de estoque e campanhas de vendas.

---

## 💡 Principais Insights

- **2009** foi o ano de maior receita — março/2009 registrou o pico do período
- Produtos **Trek** dominam em valor; produtos **Electra** dominam em volume
- **Baldwin Bikes** é a loja de maior receita em todas as categorias
- **Mountain Bikes** é a categoria líder nas três lojas sem exceção
- Ticket médio de **R$ 7.386,47** reflete o perfil premium do catálogo
- Quedas em **janeiro** e recuperações em **agosto** são padrões sazonais consistentes
