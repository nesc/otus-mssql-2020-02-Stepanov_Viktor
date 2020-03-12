
--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

Select p.FullName
  from Application.People p
 where p.IsSalesperson = 1
   and p.PersonID not in (Select SalespersonPersonID from Sales.Invoices);

With IsSalesPerson as
(Select SalespersonPersonID from Sales.Invoices
)
Select distinct p.FullName
  from Application.People p
  left join IsSalesPerson i
    on p.PersonID = i.SalespersonPersonID
 where p.IsSalesperson = 1
   and i.SalespersonPersonID is null;

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.

Select * 
  from Warehouse.StockItems s
 where s.UnitPrice = (Select min(UnitPrice) from Warehouse.StockItems);
 
 with StockItems as
(Select min(UnitPrice) as UnitPrice from Warehouse.StockItems
)
Select * 
  from Warehouse.StockItems s
 inner join StockItems si
    on si.UnitPrice = s.UnitPrice;

Select * 
  from Warehouse.StockItems s
 where s.UnitPrice = (Select top 1 UnitPrice from Warehouse.StockItems order by UnitPrice asc);
 
 with StockItems as
(Select top 1 UnitPrice from Warehouse.StockItems order by UnitPrice asc
)
Select * 
  from Warehouse.StockItems s
 inner join StockItems si
    on si.UnitPrice = s.UnitPrice;

/*
3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей 
из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
*/

Select top 5 c.CustomerID
      ,c.CustomerName
	  ,c.PhoneNumber
	  ,c.DeliveryAddressLine2
	  ,c.DeliveryAddressLine1
	  ,c.DeliveryPostalCode
	  ,ct.TransactionDate
	  ,ct.TransactionAmount
  from Sales.CustomerTransactions ct
 inner join Sales.Customers c
    on c.CustomerID = ct.CustomerID
 order by ct.TransactionAmount desc;
 
with CT as(
Select top 5 CustomerTransactionID
  from Sales.CustomerTransactions ct
 order by ct.TransactionAmount desc
)
Select c.CustomerID
      ,c.CustomerName
	  ,c.PhoneNumber
	  ,c.DeliveryAddressLine2
	  ,c.DeliveryAddressLine1
	  ,c.DeliveryPostalCode
	  ,ct.TransactionDate
	  ,ct.TransactionAmount
  from Sales.CustomerTransactions ct
 inner join CT cte
    on ct.CustomerTransactionID = cte.CustomerTransactionID
 inner join Sales.Customers c
    on c.CustomerID = ct.CustomerID
 order by ct.TransactionAmount desc;
 
select c.CustomerID
      ,c.CustomerName
	  ,c.PhoneNumber
	  ,c.DeliveryAddressLine2
	  ,c.DeliveryAddressLine1
	  ,c.DeliveryPostalCode
	  ,ct.TransactionDate
	  ,ct.TransactionAmount 
  from Sales.CustomerTransactions ct
 inner join Sales.Customers c
    on c.CustomerID = ct.CustomerID
 order by TransactionAmount desc
offset 0 rows fetch next 5 rows only

select c.CustomerID
      ,c.CustomerName
	  ,c.PhoneNumber
	  ,c.DeliveryAddressLine2
	  ,c.DeliveryAddressLine1
	  ,c.DeliveryPostalCode
	  ,d.TransactionDate
	  ,d.TransactionAmount 
from (
      select ct.TransactionAmount
            ,dense_rank() over (order by ct.TransactionAmount desc) sumRank
			,ct.CustomerID
			,ct.TransactionDate
      from Sales.CustomerTransactions ct
) d
 inner join Sales.Customers c
    on c.CustomerID = d.CustomerID
where d.sumRank <= 5
order by sumRank

/*
4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, 
а также Имя сотрудника, который осуществлял упаковку заказов
*/

with StockItemsCTE as(
Select top 3 StockItemID
  from Warehouse.StockItems si
 order by si.UnitPrice desc
)
Select distinct ci.CityID,ci.CityName, p.FullName
  from Sales.OrderLines ol
 inner join StockItemsCTE sic
    on sic.StockItemID = ol.StockItemID
 inner join Sales.Invoices i
    on i.OrderID = ol.OrderID
 inner join Application.People p
    on p.PersonID = i.PackedByPersonID
 inner join Sales.Customers c
    on c.CustomerID = i.CustomerID
 inner join Application.Cities ci
    on ci.CityID = c.DeliveryCityID


/*
5. Объясните, что делает и оптимизируйте запрос:
*/
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName FROM Application.People WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) FROM Sales.OrderLines WHERE OrderLines.OrderId = (
		SELECT Orders.OrderId FROM Sales.Orders WHERE Orders.PickingCompletedWhen IS NOT NULL AND Orders.OrderId = Invoices.OrderId)
		) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm FROM Sales.InvoiceLines GROUP BY InvoiceId HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
     ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

/*
Запрос выводит ID счета, Дату счета, ФИО продавца, Сумму счета, 
Сумму заказов, которые были упакованы.
Также присутствует условие, что сумма товаров в счете должна быть больше 27000.

SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;
*/

WITH CTEOrders (OlSum, OrderId) as (
SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
      ,OrderLines.OrderId 
  FROM Sales.OrderLines
  LEFT JOIN Sales.Orders
    ON Orders.OrderID = OrderLines.OrderID
 WHERE Orders.PickingCompletedWhen IS NOT NULL
 group by OrderLines.OrderId  
 ),
CTEInvoices (ISum, InvoiceID) as (
SELECT SUM(Quantity*UnitPrice)
      ,InvoiceId
  FROM Sales.InvoiceLines 
 GROUP BY InvoiceId 
HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT Invoices.InvoiceID
      ,Invoices.InvoiceDate
      ,People.FullName
      ,ctei.ISum AS TotalSummByInvoice
      ,cteo.OlSum AS TotalSummForPickedItems
  FROM Sales.Invoices
  JOIN Application.People
    ON People.PersonID = Invoices.SalespersonPersonID
  LEFT JOIN CTEOrders cteo
    ON cteo.OrderId = Invoices.OrderID
  JOIN CTEInvoices ctei
    ON ctei.InvoiceID = Invoices.InvoiceID
 ORDER BY ctei.ISum DESC;

/*
Прежде всего мне не понравилось, что запрос не удобно читать и анализировать из-за подзапросов.
Подзапросы с агрегированием я вынес в CTE.
Подзапрос с начиткой продавца я добавил простым джойном, поскольку ничего не мешало.
Отформатировал в привычный формат оформления.
Не совсем понимаю как улучшить производительность запроса по плану запроса.
*/

