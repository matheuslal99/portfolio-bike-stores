# 🚲 Análise de Vendas — Bike Stores

Projeto completo de análise de dados utilizando o banco de dados **Bike Stores**, cobrindo desde a verificação de qualidade dos dados em SQL Server até a construção de um dashboard interativo no Power BI. O banco contempla pedidos de 2009 a 2019, com volume expressivo concentrado entre 2009 e 2011 — período que representa mais de 97% das transações e onde os principais insights foram identificados.

> 🎮 A identidade visual do dashboard foi inspirada nos clássicos jogos de GBA — Pokémon Ruby, Sapphire e Emerald — com uma paleta de cores que remete às paisagens e à trilha sonora alegre das aventuras de bike pelos mapas do jogo.

---

## 🛠️ Ferramentas Utilizadas

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SSMS](https://img.shields.io/badge/SSMS-CC2927?style=for-the-badge&logo=microsoft&logoColor=white)

🔗 [Acesse o Dashboard no Power BI](https://app.powerbi.com/view?r=eyJrIjoiNjY2MDQzYjgtOWMyYy00MWFhLWI4MzQtMWVkMDg4ZGE1ZDk3IiwidCI6IjY1OWNlMmI4LTA3MTQtNDE5OC04YzM4LWRjOWI2MGFhYmI1NyJ9)

---

## 📁 Arquivos

| Arquivo | Descrição |
|--------|-----------|
| [`analise_vendas.sql`](./analise_vendas.sql) | Queries de verificação de qualidade e análise de vendas |

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

## 📊 Etapa 2 — Análise de Vendas em SQL

### 2.1 Receita Total por Ano e Mês

A análise da receita mensal revelou uma tendência clara de queda ao longo dos anos. O ano de 2009 concentrou os maiores volumes de receita, com destaque para março, que registrou o maior valor do período analisado. A partir de 2010 a receita cai consideravelmente, e 2011 apresenta os menores valores — chegando a menos de um terço do pico de 2009.

Esse padrão pode indicar perda de mercado, redução no catálogo de produtos ou mudança no perfil de clientes ao longo do tempo — hipóteses investigadas na etapa de visualização.

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

## 📈 Etapa 3 — Dashboard no Power BI

### 3.1 Modelagem de Dados

Antes de criar qualquer visual, o modelo de dados foi estruturado seguindo as boas práticas de modelagem dimensional — tabelas fato conectadas às tabelas dimensão com relacionamentos Um para Muitos. Uma tabela de calendário (`dim_calendario`) foi criada via DAX para garantir o correto funcionamento das funções de inteligência temporal.

---

### 3.2 Medidas DAX

Todas as métricas do dashboard foram criadas como medidas DAX explícitas, organizadas em uma tabela de medidas separada (`_Medidas`). Essa abordagem garante que os cálculos sejam consistentes em todos os visuais e contextos de filtro.

#### Medidas Base
Fundamento de todo o dashboard — calculam os valores centrais do negócio.

| Medida | Descrição técnica |
|--------|------------------|
| `Receita Total` | Utiliza `SUMX` para iterar linha a linha na tabela de itens, calculando `Quantidade × Preço × (1 - Desconto)` — garantindo o valor líquido real de cada venda |
| `Total Pedidos` | `DISTINCTCOUNT` do `OrderID` — conta pedidos únicos evitando duplicidade por itens múltiplos |
| `Ticket Medio` | `DIVIDE` entre Receita Total e Total Pedidos — usa DIVIDE em vez de "/" para tratar divisão por zero com segurança |
| `Total Unidades` | `SUM` simples da quantidade vendida por item |

#### Medidas de Inteligência Temporal
O conjunto mais sofisticado do projeto — utiliza funções DAX de time intelligence para comparações entre períodos, exigindo uma tabela de calendário marcada corretamente.

| Medida | Descrição técnica |
|--------|------------------|
| `Sales Last Year` | `CALCULATE` com `DATEADD` deslocando o contexto de data em -1 ano — retorna a receita do mesmo período no ano anterior |
| `Sales Last Year Delta %` | Variação percentual entre a receita atual e `Sales Last Year` — mede o crescimento ou queda ano a ano (YoY) |
| `Sales Last Month` | `CALCULATE` com `DATEADD` deslocando o contexto em -1 mês |
| `Sales Last Month Delta %` | Variação percentual mês a mês (MoM) — permite identificar sazonalidade e tendências de curto prazo |
| `Sales Year to Date` | `TOTALYTD` acumula a receita do início do ano até a data atual do contexto — essencial para acompanhamento de metas anuais |

#### Medidas Analíticas
Usadas para rankings e análises comparativas entre produtos.

| Medida | Descrição técnica |
|--------|------------------|
| `Rank Produto` | `RANKX` com `ALL` na tabela de produtos — calcula o ranking global de receita ignorando filtros locais, permitindo comparar qualquer produto contra o catálogo completo |
| `Sales Qtde` | Quantidade vendida no contexto filtrado — usada separadamente de `Total Unidades` para contextos específicos de visual |

---

### 3.3 Páginas do Dashboard

#### Página 1 — Visualização de Vendas
Visão geral da receita com comparativo ano anterior, distribuição por loja e categoria, sazonalidade mensal e top 10 produtos. Conta com menu lateral deslizante com filtros de loja e categoria, e tooltips interativos ao passar o mouse sobre produtos e lojas.

#### Página 2 — Visualização de Produtos
Análise do catálogo com ranking de produtos mais vendidos por receita e por volume, receita por marca e o gráfico de dispersão **Receita vs. Volume por Marca** — que revela dois perfis de cliente completamente distintos ao posicionar cada marca pelo binômio receita × unidades vendidas, com o tamanho da bolinha representando o ticket médio.

#### Página 3 — Vendas Detalhadas
Página de drill through acessível ao clicar com botão direito em qualquer categoria nos gráficos. Exibe tabela hierárquica completa por categoria e produto com receita, unidades, comparativo com ano anterior, variação mensal com formatação condicional verde/vermelho e ranking global.

---

## 💡 Principais Insights

**Concentração em Baldwin Bikes** — a loja representa 70,44% da receita total. Um risco de concentração significativo para o negócio.

**Mountain Bikes sustenta o negócio** — a categoria representa sozinha mais de 36% da receita total e lidera em todas as lojas sem exceção.

**Dois perfis de cliente completamente diferentes** — produtos Trek lideram em receita com alto ticket médio e menor volume, enquanto produtos Electra e Surly dominam em unidades vendidas com ticket mais acessível. Isso é visível no gráfico de dispersão da página de produtos.

**Trek Slash 8 27.5 é o produto estrela** — Rank 1 global, maior receita individual e presença constante nos top 10 de todos os anos analisados.

**Sazonalidade clara e acionável** — março é consistentemente o melhor mês do ano, janeiro o pior. Esse padrão se repete em todos os anos e todas as lojas — um indicativo direto para planejamento de estoque e campanhas.

**Queda estrutural de receita** — a receita caiu de forma consistente ao longo do período analisado, não sendo apenas sazonalidade. O volume de pedidos caiu de 59.376 em 2009 para menos de 700 em 2019, sugerindo uma retração severa do negócio. O dashboard permite investigar essa tendência por loja, categoria e produto de forma interativa.
