USE BikeStores

-- Verificando nulos nas colunas principais
SELECT
    SUM(CASE WHEN OrderID    IS NULL THEN 1 ELSE 0 END) AS nulos_order_id,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS nulos_customer_id,
    SUM(CASE WHEN OrderDate  IS NULL THEN 1 ELSE 0 END) AS nulos_order_date,
    SUM(CASE WHEN [Status] IS NULL THEN 1 ELSE 0 END) AS nulos_status
FROM Sales.[Order];

-- Verificando status de pedidos existentes
SELECT STATUS, COUNT(*) AS Total
FROM Sales.[Order]
GROUP BY STATUS;

-- Verificando pedidos duplicados
SELECT OrderID, COUNT(*) AS Ocorrencias
FROM Sales.[Order]
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- Preços e descontos fora do intervalo esperado
SELECT *
FROM Sales.OrderItem
WHERE ListPrice <= 0
   OR Discount < 0
   OR Discount > 1;  

-- Pedidos com data de envio ANTES da data do pedido
SELECT *
FROM Sales.[Order]
WHERE ShippedDate < OrderDate;

-- View limpa sem datas suspeitas
CREATE VIEW Sales.Orders_Clean AS
SELECT *
FROM Sales.[Order]
WHERE Status = 4
  AND NOT (DATEPART(DAY, OrderDate) = 31
           AND DATEPART(MONTH, OrderDate) = 12);

-- Evolução da receita ao longo do ano
SELECT
    DATEPART(YEAR, O.OrderDate)  AS Ano,
    DATEPART(MONTH, O.OrderDate) AS Mes,
    SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
FROM Sales.Orders_Clean O
JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderID
GROUP BY
    DATEPART(YEAR, O.OrderDate),
    DATEPART(MONTH, O.OrderDate)
ORDER BY Ano, Mes;

-- Meses com maior receita
SELECT
    DATEPART(YEAR, O.OrderDate)  AS Ano,
    DATEPART(MONTH, O.OrderDate) AS Mes,
    SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
FROM Sales.Orders_Clean O
JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
GROUP BY
    DATEPART(YEAR, O.OrderDate),
    DATEPART(MONTH, O.OrderDate)
ORDER BY Receita_Total DESC;

-- Produtos que mais geraram receita
SELECT TOP 10
    P.Name,
    SUM(Oi.Quantity) AS Total_Unidades,
    SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
FROM Sales.Orders_Clean O
JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
JOIN Production.Product P  ON Oi.ProductId = P.ProductId
GROUP BY P.Name
ORDER BY Receita_Total DESC;

-- TOP 10 por Unidades Vendidas
SELECT TOP 10
    P.Name,
    SUM(Oi.Quantity) AS Total_Unidades,
    SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
FROM Sales.Orders_Clean O
JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
JOIN Production.Product P  ON Oi.ProductId = P.ProductId
GROUP BY P.Name
ORDER BY Total_Unidades DESC;

-- Receita por loja e categoria de produto
SELECT
    S.Name,
    C.Name,
    SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
FROM Sales.Orders_Clean O  
JOIN Sales.OrderItem Oi ON O.OrderID    = Oi.OrderID
JOIN Sales.Store S ON O.StoreId = S.StoreID
JOIN Production.Product P ON Oi.ProductID = P.ProductID
JOIN Production.Category C ON P.CategoryID = C.CategoryID
GROUP BY S.Name, C.Name
ORDER BY S.Name, Receita_Total DESC;

-- Valor médio gasto por pedido
WITH Receita_Por_Pedido AS (
    SELECT
        O.OrderId,
        SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Valor_Pedido
    FROM Sales.Orders_Clean O
    JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
    GROUP BY O.OrderId
)
SELECT
    ROUND(AVG(Valor_Pedido), 2) AS Ticket_Medio
FROM Receita_Por_Pedido;

-- Ticket médio por loja e ano
WITH Receita_Por_Pedido AS (
    SELECT
        O.OrderId,
        O.StoreId,
        DATEPART(YEAR, O.OrderDate) AS Ano,
        SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Valor_Pedido
    FROM Sales.Orders_Clean O
    JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
    GROUP BY O.OrderId, O.StoreId, DATEPART(YEAR, O.OrderDate)
)
SELECT
    S.Name,
    Ano,
    ROUND(AVG(Valor_Pedido), 2) AS Ticket_Medio
FROM Receita_Por_Pedido R
JOIN Sales.Store S  ON R.StoreId = S.StoreId
GROUP BY S.Name, Ano
ORDER BY S.Name, Ano;

-- Quantos pedidos em 2019 por loja?
SELECT
    S.Name,
    DATEPART(YEAR, O.OrderDate) AS Ano,
    COUNT(O.OrderId) AS Total_Pedidos
FROM Sales.Orders_Clean O
JOIN Sales.Store S ON O.StoreId = S.StoreId
WHERE DATEPART(YEAR, O.OrderDate) = 2019
GROUP BY S.Name, DATEPART(YEAR, O.OrderDate)
ORDER BY S.Name;

-- Variação percentual da receita em relação ao mês anterior
WITH Receita_Mensal AS (
    SELECT
        DATEPART(YEAR, O.OrderDate) AS Ano,
        DATEPART(MONTH, O.OrderDate) AS Mes,
        SUM(Oi.Quantity * Oi.ListPrice * (1 - Oi.Discount)) AS Receita_Total
    FROM Sales.Orders_Clean O
    JOIN Sales.OrderItem Oi ON O.OrderId = Oi.OrderId
    GROUP BY
        DATEPART(YEAR, O.OrderDate),
        DATEPART(MONTH, O.OrderDate)
)
SELECT
    Ano,
    Mes,
    ROUND(Receita_Total, 2) AS Receita_Total,
    ROUND(LAG(Receita_Total) OVER (ORDER BY Ano, Mes), 2) AS Receita_Mes_Anterior,
    ROUND(
        (Receita_Total - LAG(Receita_Total) OVER (ORDER BY Ano, Mes))
        / LAG(Receita_Total) OVER (ORDER BY Ano, Mes) * 100
    , 2) AS Crescimento_Pct
FROM Receita_Mensal
ORDER BY Ano, Mes;
