
--1. Все товары, в которых в название есть пометка urgent или название начинается с Animal

Select *
  from Warehouse.StockItems
 where StockItemName like '%urgent%'
    or StockItemName like 'Animal%';

--2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)

Select s.SupplierName as 'Supplier'
  from Purchasing.Suppliers s
  left join Warehouse.StockItems i
    on i.SupplierID = s.SupplierID
 where i.StockItemID is null;

/*
3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. 
*/

Select o.CustomerPurchaseOrderNumber as 'Order number'
      ,DATENAME(mm,o.orderdate) as 'Mounth'
	  ,DATENAME(Quarter,o.orderdate) as 'Quarter'
	  ,CAST((DATEPART(mm, o.OrderDate) - 1) / 4 as int) + 1 as 'Third'
	  ,i.UnitPrice as 'Price'
	  ,i.QuantityPerOuter as 'Quantity'
  from Sales.Orders o
 inner join Sales.OrderLines ol
    on ol.OrderID = o.OrderID
 inner join Warehouse.StockItems i
    on i.StockItemID = ol.StockItemID
 where i.UnitPrice > 100
    or i.QuantityPerOuter > 20;

/*
Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
Соритровка должна быть по номеру квартала, трети года, дате продажи.
*/

Select o.CustomerPurchaseOrderNumber as 'Order number'
      ,o.orderdate as 'Date'
      ,DATENAME(mm,o.orderdate) as 'Mounth'
	  ,DATENAME(Quarter,o.orderdate) as 'Quarter'
	  ,CAST((DATEPART(mm, o.OrderDate) - 1) / 4 as int) + 1 as 'Third'
	  ,i.UnitPrice as 'Price'
	  ,i.QuantityPerOuter as 'Quantity'
  from Sales.Orders o
 inner join Sales.OrderLines ol
    on ol.OrderID = o.OrderID
 inner join Warehouse.StockItems i
    on i.StockItemID = ol.StockItemID
 where i.UnitPrice > 100
    or i.QuantityPerOuter > 20
 order by Quarter, Third, Date
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY; 

/*
4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, 
добавьте название поставщика, имя контактного лица принимавшего заказ
*/

Select po.OrderDate as 'Date'
      ,po.SupplierReference 'Supplier reference'
      ,s.SupplierName as 'Supplier'
      ,p.FullName as 'Contact person'
	  ,d.DeliveryMethodName as 'Delivery Method'
  from Purchasing.PurchaseOrders po
 inner join Application.DeliveryMethods d
    on d.DeliveryMethodID = po.DeliveryMethodID
 inner join Purchasing.Suppliers s
    on s.SupplierID = po.SupplierID
 inner join Application.People p
    on p.PersonID = po.ContactPersonID
 where YEAR(po.orderdate) = '2014'
   and d.DeliveryMethodName in ('Road Freight', 'Post');

--5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.

Select top 10 o.OrderDate 'Date'
      ,o.CustomerPurchaseOrderNumber as 'Number'
	  ,p1.FullName as 'Customer'
	  ,p2.FullName as 'Sales person'
  from Sales.Orders o
 inner join Application.People p1
    on p1.PersonID = o.ContactPersonID
 inner join Application.People p2
    on p2.PersonID = o.SalespersonPersonID
 order by o.OrderDate desc;

--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g

Select o.ContactPersonID as 'ID customer'
      ,p.FullName as 'Name'
	  ,p.PhoneNumber as 'Phone'
  from Sales.Orders o
 inner join Sales.OrderLines ol
    on ol.OrderID = o.OrderID
 inner join Warehouse.StockItems s
    on s.StockItemID = ol.StockItemID
 inner join Application.People p
    on p.PersonID = o.ContactPersonID
 where s.StockItemName = 'Chocolate frogs 250g'
