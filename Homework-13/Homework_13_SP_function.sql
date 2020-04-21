--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.

Create function GetCustomerWithMaxSum()
Returns Table
as
Return
(
  with CTE as (
Select distinct sum(il.UnitPrice) OVER (Partition by il.InvoiceID) as 'summ'
      ,InvoiceID
  from Sales.InvoiceLines il
), 
CTE2 as (
Select max(summ) Msum
  from CTE
)
Select cu.CustomerName
  from CTE c
 inner join Sales.Invoices i
    on i.InvoiceID = c.InvoiceID
 inner join Sales.Customers cu
    on cu.CustomerID = i.CustomerID
 where summ = (Select Msum from CTE2)
);

Select * from GetCustomerWithMaxSum();

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

Create procedure GetSumInvoiceByCustomer 
                 @CustomerID int
as
Select distinct c.CustomerName
      ,sum(il.UnitPrice) OVER ()
  from Sales.Customers c with (index=PK_Sales_Customers)
 inner join Sales.Invoices i with (index=FK_Sales_Invoices_CustomerID)
    on i.CustomerID = i.CustomerID
 inner join Sales.InvoiceLines il with (index=FK_Sales_InvoiceLines_InvoiceID)
    on il.InvoiceID = i.InvoiceID
 where c.CustomerID = @CustomerID
GO

exec GetSumInvoiceByCustomer
     @CustomerID = 1;

--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
--Создам фунцию аналогичную 2 заданию и сравню их

Create function GetSumInvoiceByCustomerF(@CustomerID int)
Returns Table
as
Return
(
Select distinct c.CustomerName
      ,sum(il.UnitPrice) OVER () as 'Summ'
  from Sales.Customers c with (index=PK_Sales_Customers)
 inner join Sales.Invoices i with (index=FK_Sales_Invoices_CustomerID)
    on i.CustomerID = i.CustomerID
 inner join Sales.InvoiceLines il with (index=FK_Sales_InvoiceLines_InvoiceID)
    on il.InvoiceID = i.InvoiceID
 where c.CustomerID = @CustomerID
);

exec GetSumInvoiceByCustomer
     @CustomerID = 1;
	 
Select * from GetSumInvoiceByCustomerF(1);

--1. Нельзя создать функцию и процедуру с одинаковыми именами
--2. Планы разделились на 50% и 50%
--3. Они идентичны. Думаю нужно более сложные вычисления внутри процедуры и функции, но в задании об этом не указано.



--4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

Create function GetSumInvoiceByInvoiceID(@InvoiceID int)
Returns Table
as
Return
(
Select distinct Sum(il.UnitPrice) OVER (Partition by i.InvoiceID) as 'SumUnitPrice'
      ,i.InvoiceID as 'InvoiceID'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
);

Select top 10 i.InvoiceDate
      ,i.InvoiceID
	  ,(Select f.SumUnitPrice from GetSumInvoiceByInvoiceID(i.InvoiceID) f where i.InvoiceID = f.InvoiceID) as 'SumUnitPrice'
  from Sales.Invoices i

--Во всех процедурах, в описании укажите для преподавателям
--5) какой уровень изоляции нужен и почему.

--На мой взгляд для всех функций которые я использовал в этом домашнем задании достаточно уровня изоляции по умолчанию READ COMMITTED
--Также для ускорения получения данных я бы использовал READ UNCOMMITTED потому что мои функции и процедуры состоят из одного запроса и выполняться будут одномоментно.
--Ставить более строгий уровень изоляции смысла нет в данном случае.

--Вот если бы в функции или процедуре происходило бы изменение данных, тогда я бы предпочел REPEATABLE READ

--Использование SNAPSHOT ISOLATION и SERIALIZABLE на мой взгляд опасно. Надо четко понимать в какой момент времени это вынужденная мера. При этом транзакция должна быть быстрой и отказоустойчивой