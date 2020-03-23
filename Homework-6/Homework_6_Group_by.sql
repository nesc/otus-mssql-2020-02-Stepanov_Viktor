﻿--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

Select DATEPART(yyyy,i.InvoiceDate) as 'Год'
      ,DATEPART(MM,i.InvoiceDate)	as 'Месяц'
      ,AVG(s.UnitPrice)				as 'Средняя цена товара'
	  ,Sum(il.UnitPrice)            as 'Общая сумма продажи по месяцам'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 inner join Warehouse.StockItems s
    on s.StockItemID = il.StockItemID
 group by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate)
 order by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate);

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Select DATEPART(yyyy,i.InvoiceDate)	as 'Год'
      ,DATEPART(MM,i.InvoiceDate)	as 'Месяц'
      ,Sum(il.UnitPrice)			as 'Общая сумма продажи по месяцам'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 group by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate), DateName(mm,i.InvoiceDate)
having Sum(il.UnitPrice) > 10000
 order by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate);

/*
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году и месяцу.
*/

Select DATEPART(yyyy,i.InvoiceDate)	as 'Год'
      ,DATEPART(MM,i.InvoiceDate)	as 'Месяц'
      ,Sum(il.UnitPrice)			as 'Сумма продаж'
      ,Min(i.InvoiceDate)			as 'Дата первой продажи'
	  ,count(il.Quantity)			as 'Количество проданного'
	  ,s.StockItemName				as 'Наименование товара'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 inner join Warehouse.StockItems s
    on s.StockItemID = il.StockItemID
 group by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate), s.StockItemName
having sum(il.Quantity) < 50
 order by DATEPART(yyyy,i.InvoiceDate), DATEPART(MM,i.InvoiceDate);

 /*
 4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
Дано :
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1 Ken Sánchez Chief Executive Officer 1
273 | Brian Welcker Vice President of Sales 2
16 | | David Bradley Marketing Manager 3
23 | | | Mary Gibson Marketing Specialist 4
274 | | Stephen Jiang North American Sales Manager 3
276 | | | Linda Mitchell Sales Representative 4
275 | | | Michael Blythe Sales Representative 4
285 | | Syed Abbas Pacific Sales Manager 3
286 | | | Lynn Tsoflias Sales Representative 4
 */

  with CTE(EmployeeID, ManagerID, EmployeeLevel) as (
Select EmployeeID
	  ,ManagerID
	  ,1
  from dbo.MyEmployees
 where ManagerID is null

 union all

Select e.EmployeeID
	  ,e.ManagerID
	  ,c.EmployeeLevel + 1
  from dbo.MyEmployees e
 inner join CTE c
    on c.EmployeeID = e.ManagerID
)
Select c.EmployeeID						as 'EmployeeID'
      ,Replicate('| ', c.EmployeeLevel-1) + m.FirstName + ' ' + m.LastName	as 'Name'
	  ,m.Title							as 'Title'
	  ,c.EmployeeLevel
  from CTE c
 inner join dbo.MyEmployees m
    on m.EmployeeID = c.EmployeeID;
