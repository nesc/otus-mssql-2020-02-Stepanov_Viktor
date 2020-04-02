/*
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/

with CTE as (
Select distinct substring(CustomerName, charindex('(',CustomerName)+1, charindex(')',CustomerName) - charindex('(',CustomerName)-1) as 'CustomerName'
      ,Format(i.InvoiceDate,'01.MM.yyyy')	as 'InvoiceMonth'
	  ,i.InvoiceID							as 'InvoiceID'
  from Sales.Customers c
 inner join Sales.Invoices i
    on i.CustomerID = c.CustomerID
 where c.CustomerID in (2, 3, 4, 5, 6)
 )
 Select * from CTE
 Pivot (count(InvoiceID)
 for CustomerName in ([Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Sylvanite, MT],[Jessie, ND]))
 as Pvt
 order by Year(InvoiceMonth), Month(InvoiceMonth);

/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
.....
*/

with CTE as (
Select c.CustomerName			as 'CustomerName'
      ,c.DeliveryAddressLine1	as 'DeliveryAddressLine1'
	  ,c.DeliveryAddressLine2	as 'DeliveryAddressLine2'
	  ,c.PostalAddressLine1		as 'PostalAddressLine1'
	  ,c.PostalAddressLine2		as 'PostalAddressLine2'
  from Sales.Customers c
 where c.CustomerName like 'Tailspin Toys%'
)
Select * from CTE
Unpivot(AddressLine for TypeAddress in ([DeliveryAddressLine1],[DeliveryAddressLine2],[PostalAddressLine1],[PostalAddressLine2])) as Unp;

/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
*/

with CTE as (
Select c.CountryID								as 'CountryID'
      ,c.CountryName							as 'CountryName'
	  ,Convert(varchar(3), c.IsoAlpha3Code)		as 'IsoAlpha3Code'
	  ,Convert(varchar(3), c.IsoNumericCode)	as 'IsoNumericCode'
  from Application.Countries c
)
Select * from CTE
Unpivot(Code for CodeType in ([IsoAlpha3Code],[IsoNumericCode])) as unpvt;

/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

Select c.CustomerID	as 'ID покупателя'
      ,c.CustomerName	as 'Имя покупателя'
	  ,top2.StockItemID	as 'ID товара'
	  ,top2.StockItemName	as 'Название товара'
	  ,top2.UnitPrice	as 'Цена товара'
	  ,top2.OrderDate	as 'Дата заказа'
  from Sales.Customers c
CROSS APPLY (Select top 2 ol.StockItemID, ol.UnitPrice, o.OrderDate, si.StockItemName
               from Sales.Orders o
              inner join Sales.OrderLines ol
                 on ol.OrderID = o.OrderID
              inner join Warehouse.StockItems si
                 on si.StockItemID = ol.StockItemID
			  where o.CustomerID = c.CustomerID
             ) as top2
 order by c.CustomerID;

