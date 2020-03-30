--1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.

--Через #Таблицу
Drop table if exists #Sums;

Create table #Sums (Sum        numeric(12,2)
                   ,yy         varchar(4)
                   ,mm         varchar(2)
				   ,SumMMTotal numeric(12,2)
				   );

Insert #Sums (Sum, yy, mm, SumMMTotal)
Select sum(il.UnitPrice)    as 'Sum'
      ,YEAR(i.InvoiceDate)  as 'yy'
      ,MONTH(i.InvoiceDate) as 'mm'
	  ,isnull(sum(il.UnitPrice) + (
                            Select sum(il2.UnitPrice)
                              from Sales.Invoices i2
                             inner join Sales.InvoiceLines il2
                                on il2.InvoiceID = i2.InvoiceID
							 where MONTH(i2.InvoiceDate) < MONTH(i.InvoiceDate)
							   and YEAR(i2.InvoiceDate) = YEAR(i.InvoiceDate)
							--having ((YEAR(i2.InvoiceDate) = YEAR(i.InvoiceDate) and MONTH(i2.InvoiceDate)+1 = MONTH(i.InvoiceDate)) or (YEAR(i2.InvoiceDate)+1 = YEAR(i.InvoiceDate) and MONTH(i2.InvoiceDate)-11 = MONTH(i.InvoiceDate) and MONTH(i.InvoiceDate) = 1and MONTH(i2.InvoiceDate) = 12))
						   ),sum(il.UnitPrice)) as 'SumMMTotal'
 from Sales.Invoices i
inner join Sales.InvoiceLines il
   on il.InvoiceID = i.InvoiceID
where YEAR(i.InvoiceDate) >= 2015
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);

Select distinct i.InvoiceDate
	  ,s.SumMMTotal
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 inner join #Sums s
    on s.yy = YEAR(i.InvoiceDate)
   and s.mm = MONTH(i.InvoiceDate)
 order by i.InvoiceDate;
 
--Через Табличную переменную
Declare @Sums table(Sum        numeric(12,2)
                   ,yy         varchar(4)
                   ,mm         varchar(2)
				   ,SumMMTotal numeric(12,2)
				   );

Insert @Sums (Sum, yy, mm, SumMMTotal)
Select sum(il.UnitPrice)    as 'Sum'
      ,YEAR(i.InvoiceDate)  as 'yy'
      ,MONTH(i.InvoiceDate) as 'mm'
	  ,isnull(sum(il.UnitPrice) + (
                            Select sum(il2.UnitPrice)
                              from Sales.Invoices i2
                             inner join Sales.InvoiceLines il2
                                on il2.InvoiceID = i2.InvoiceID
							 where MONTH(i2.InvoiceDate) < MONTH(i.InvoiceDate)
							   and YEAR(i2.InvoiceDate) = YEAR(i.InvoiceDate)
							--having ((YEAR(i2.InvoiceDate) = YEAR(i.InvoiceDate) and MONTH(i2.InvoiceDate)+1 = MONTH(i.InvoiceDate)) or (YEAR(i2.InvoiceDate)+1 = YEAR(i.InvoiceDate) and MONTH(i2.InvoiceDate)-11 = MONTH(i.InvoiceDate) and MONTH(i.InvoiceDate) = 1and MONTH(i2.InvoiceDate) = 12))
						   ),sum(il.UnitPrice)) as 'SumMMTotal'
 from Sales.Invoices i
inner join Sales.InvoiceLines il
   on il.InvoiceID = i.InvoiceID
where YEAR(i.InvoiceDate) >= 2015
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)

Select distinct i.InvoiceDate
	  ,s.SumMMTotal
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 inner join @Sums s
    on s.yy = YEAR(i.InvoiceDate)
   and s.mm = MONTH(i.InvoiceDate)
 order by i.InvoiceDate;

/*
2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/

--Через оконную функцию
with CTE as (
Select distinct Year(i.InvoiceDate) as 'yy'
      ,Month(i.InvoiceDate)         as 'mm'
      ,sum(il.UnitPrice) OVER (order by Year(i.InvoiceDate), Month(i.InvoiceDate)) as 'SumMMTotal'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 where YEAR(i.InvoiceDate) >= 2015
)
Select distinct i.InvoiceDate
	  ,CTE.SumMMTotal
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 inner join CTE
    on CTE.yy = YEAR(i.InvoiceDate)
   and CTE.mm = MONTH(i.InvoiceDate)
 order by i.InvoiceDate;

/*
2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год 
(по 2 самых популярных продукта в каждом месяце)
*/

with CTE as (
Select MONTH(i.InvoiceDate)		as 'mm'
	  ,Count(il.StockItemID)	as 'iCount'
	  ,DENSE_RANK() OVER (Partition by MONTH(i.InvoiceDate) order by Count(il.StockItemID) desc) as 'DRank'
	  ,il.StockItemID
	  --,si.StockItemName			as 'SName'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
 where YEAR(i.InvoiceDate) = 2016
 group by MONTH(i.InvoiceDate),il.StockItemID
 )
Select '2016'			as 'Год'
      ,CTE.mm			as 'Месяц'
	  ,si.StockItemName as 'Название товара'
	  ,CTE.iCount		as 'Количество'
  from CTE
 inner join Warehouse.StockItems si
    on si.StockItemID = CTE.StockItemID
 where DRank <= 2;

/*
3. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/

Select si.StockItemID																	as 'ID'
      ,si.StockItemName																	as 'Название товара'
	  ,si.Brand																			as 'Брэнд'
	  ,si.UnitPrice																		as 'Цена'
	  ,DENSE_RANK() OVER (order by substring(si.StockItemName,1,1) asc)					as 'DRank_bukv' --пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
	  ,Count(si.StockItemID) OVER ()													as 'Общее к-во товаров' --посчитайте общее количество товаров и выведете полем в этом же запросе
	  ,Count(si.StockItemID) OVER (partition by substring(si.StockItemName,1,1))		as 'Общ. к-во тов. от перв. бук.' --посчитайте общее количество товаров в зависимости от первой буквы названия товара
	  ,Lead(si.StockItemID) OVER (order by si.StockItemName asc)						as 'След ID' --отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
	  ,Lag(si.StockItemID) OVER (order by si.StockItemName asc)							as 'Пред ID' --предыдущий ид товара с тем же порядком отображения (по имени)
	  ,isnull(Lag(si.StockItemName,2) OVER (order by si.StockItemName asc),'No items')	as 'Пред 2 стр назад' --названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
	  ,NTILE(30) OVER (order by si.TypicalWeightPerUnit)								as '30 групп' --сформируйте 30 групп товаров по полю вес товара на 1 шт
  from Warehouse.StockItems si
 order by si.StockItemName;

/*
4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/

with CTE as (
Select distinct o.SalespersonPersonID					as 'SalespersonPersonID'
      ,DENSE_RANK() OVER (Partition by o.SalespersonPersonID order by o.OrderID desc) as 'DRank'
	  ,o.CustomerID										as 'CustomerID'
	  ,o.OrderDate										as 'OrderDate'
	  ,o.OrderID										as 'OrderID'
	  ,sum(ol.UnitPrice) OVER (Partition by o.OrderID)	as 'oSum'
  from Sales.Orders o
 inner join Sales.OrderLines ol
    on ol.OrderID = o.OrderID
)
Select CTE.SalespersonPersonID	as 'ID продавца'
      ,ps.FullName				as 'Имя продавца'
	  ,CTE.CustomerID			as 'ID покупателя'
	  ,c.CustomerName			as 'Имя покупателя'
	  ,CTE.OrderDate			as 'Дата продажи'
	  ,CTE.oSum					as 'Сумма заказа'
  from CTE
 inner join Application.People ps
    on ps.PersonID = CTE.SalespersonPersonID
 inner join Sales.Customers c
    on c.CustomerID = CTE.CustomerID
 where CTE.DRank = 1;
  
/*
5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

with CTE as (
Select distinct o.CustomerID	as 'CustomerID'
      ,ol.StockItemID			as 'StockItemID'
	  ,DENSE_RANK() OVER (Partition by o.CustomerID order by ol.UnitPrice desc) as 'DRank'
	  ,o.OrderDate				as 'OrderDate'
	  ,ol.UnitPrice				as 'UnitPrice'
  from Sales.Orders o
 inner join Sales.OrderLines ol
    on ol.OrderID = o.OrderID
)
Select CTE.CustomerID	as 'ID покупателя'
      ,c.CustomerName	as 'Имя покупателя'
	  ,CTE.StockItemID	as 'ID товара'
	  ,si.StockItemName	as 'Название товара'
	  ,CTE.UnitPrice	as 'Цена товара'
	  ,CTE.OrderDate	as 'Дата заказа'
  from CTE
 inner join Warehouse.StockItems si
    on si.StockItemID = CTE.StockItemID
 inner join Sales.Customers c
    on c.CustomerID = CTE.CustomerID
 where CTE.DRank <= 2
 order by CTE.CustomerID;

/*
Bonus из предыдущей темы
Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов и последний заказ был не позднее апреля 2016
*/
Drop table if exists #Temp
GO

Create table #Temp (LastOrderDate	date
                   ,CustomerID		int
				   );

Insert into #Temp
Select Max(o.OrderDate)	as 'LastOrderDate'
      ,o.CustomerID		as 'CustomerID'
  from Sales.Orders o
 group by o.CustomerID
having count(o.OrderID) > 30;

Select distinct top 10 t.CustomerID
      ,t.LastOrderDate
  from #Temp t
 inner join Sales.Orders o
    on o.CustomerID = t.CustomerID
 where t.LastOrderDate < '20160501';