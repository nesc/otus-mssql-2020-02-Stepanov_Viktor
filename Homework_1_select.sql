
--1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal

Select *
  from Warehouse.StockItems
 where StockItemName like '%urgent%'
    or StockItemName like 'Animal%';

--2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)

Select s.SupplierName as 'Supplier'
  from Purchasing.Suppliers s
  left join Warehouse.StockItems i
    on i.SupplierID = s.SupplierID
 where i.StockItemID is null;

/*
3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������, 
�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, ���� ������ ������ ������ ���� ������, 
� ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20. 
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
�������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� ��������� 100 �������. 
���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.
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
4. ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post, 
�������� �������� ����������, ��� ����������� ���� ������������ �����
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

--5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.

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

--6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g

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
