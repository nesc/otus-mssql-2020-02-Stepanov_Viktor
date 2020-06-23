SET STATISTICS IO, TIME ON

--Исходный запрос
Select ord.CustomerID
      ,det.StockItemID
	  ,SUM(det.UnitPrice)
	  ,SUM(det.Quantity)
	  ,COUNT(ord.OrderID) 
  FROM Sales.Orders AS ord 
  JOIN Sales.OrderLines AS det 
    ON det.OrderID = ord.OrderID 
  JOIN Sales.Invoices AS Inv 
    ON Inv.OrderID = ord.OrderID 
  JOIN Sales.CustomerTransactions AS Trans 
    ON Trans.InvoiceID = Inv.InvoiceID 
  JOIN Warehouse.StockItemTransactions AS ItemTrans 
    ON ItemTrans.StockItemID = det.StockItemID 
 WHERE Inv.BillToCustomerID != ord.CustomerID 
   AND (Select SupplierId 
          FROM Warehouse.StockItems AS It 
		 Where It.StockItemID = det.StockItemID) = 12 
   AND (SELECT SUM(Total.UnitPrice*Total.Quantity) 
          FROM Sales.OrderLines AS Total 
		  Join Sales.Orders AS ordTotal 
		    On ordTotal.OrderID = Total.OrderID 
		 WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
   AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 
 GROUP BY ord.CustomerID, det.StockItemID 
 ORDER BY ord.CustomerID, det.StockItemID

--Запрос из задания
--										CPU				Elapsed
--SQL Server parse and compile time:	00:00:00.125	00:00:00.166
--SQL Server Execution Times:			00:00:01.125	00:00:01.580
--Total									00:00:01.250	00:00:01.746

--=====================================================================
--Запрос после оптимизации
--										CPU				Elapsed
--SQL Server parse and compile time:	00:00:00.063	00:00:00.066
--SQL Server Execution Times:			00:00:00.297	00:00:00.616
--Total									00:00:00.360	00:00:00.682

--Шаги
--1) Избавимся от бесполезной функции "DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0"
--Количество дней между Inv.InvoiceDate и ord.OrderDate равное 0 означает, что даты равны друг другу
--2) Уберем подзапросы из where
	--2.1) Первый подзапрос превращаем в JOIN
	--2.2) Второй подзапрос выносим в временную таблицу с индексом и убераем оконную функцию
--3) В плане запросов видно, что используется Clustered index scan PK_Sales_Invoices в таблице Sales.Invoices
--4) Избавляемся от group by и агрегатов в основном запросе, вынося их в временную таблицу с покрывающим индексом
--10) Привести к единому стилю


--Опитимизированный 

CREATE INDEX F_Sales_Invoices_N ON Sales.Invoices(CustomerID) include (OrderID, BillToCustomerID, InvoiceDate)

DROP TABLE IF EXISTS #Temp
DROP TABLE IF EXISTS #Temp2

CREATE TABLE #Temp (TotalSum decimal(18,2), CustomerID int)
CREATE INDEX FK_Temp_CustomerID ON #Temp(CustomerID)

CREATE TABLE #Temp2 (SumUnitPrice decimal(18,2), SumQuantity decimal(18,2), CountOrderID int, StockItemID int, CustomerID int)
CREATE INDEX FK_Temp2_CustomerID_StockItemID ON #Temp2(CustomerID, StockItemID) include (SumUnitPrice, SumQuantity, CountOrderID)


INSERT #Temp (TotalSum, CustomerID)
SELECT DISTINCT SUM(Total.UnitPrice*Total.Quantity)
      ,ordTotal.CustomerID AS CustomerID
  FROM Sales.OrderLines AS Total 
  JOIN Sales.Orders AS ordTotal 
    On ordTotal.OrderID = Total.OrderID 
 GROUP BY ordTotal.CustomerID
 
INSERT #Temp2 (SumUnitPrice, SumQuantity, CountOrderID, CustomerID, StockItemID)
SELECT DISTINCT SUM(det.UnitPrice)
      ,SUM(det.Quantity)
	  ,COUNT(ord.OrderID) 
	  ,ord.CustomerID AS CustomerID
	  ,det.StockItemID AS StockItemID
  FROM Sales.Orders AS ord 
  JOIN Sales.OrderLines AS det 
    ON det.OrderID = ord.OrderID 
  JOIN Warehouse.StockItems AS It
    ON It.StockItemID = det.StockItemID
   AND It.SupplierId = 12
  JOIN Warehouse.StockItemTransactions AS ItemTrans 
    ON ItemTrans.StockItemID = det.StockItemID 
 GROUP BY ord.CustomerID, det.StockItemID

Select DISTINCT ord.CustomerID
      ,det.StockItemID
	  ,t2.SumUnitPrice
	  ,t2.SumQuantity
	  ,t2.CountOrderID
  FROM #Temp t
  JOIN Sales.Invoices AS Inv 
    ON t.CustomerID = Inv.CustomerID
   AND t.TotalSum > 250000
  JOIN Sales.Orders AS ord
    ON ord.OrderID = Inv.OrderID
  JOIN Sales.OrderLines AS det 
    ON det.OrderID = ord.OrderID 
  JOIN #Temp2 t2
    ON t2.StockItemID = det.StockItemID
   and t2.CustomerID = ord.CustomerID
  JOIN Sales.CustomerTransactions AS Trans 
    ON Trans.InvoiceID = Inv.InvoiceID 
 WHERE Inv.BillToCustomerID != t2.CustomerID 
   AND Inv.InvoiceDate = ord.OrderDate 
 ORDER BY ord.CustomerID, det.StockItemID
