--1. �������� ������ � ��������� �������� � ���������� ��� � ��������� ����������. �������� �����.

--����� #�������
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
 
--����� ��������� ����������
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
2. ���� �� ����� ������������ ���� ������, �� �������� ������ ����� ����������� ������ � ������� ������� �������.
�������� 2 �������� ������� - ����� windows function � ��� ���. �������� ����� ������� �����������, �������� �� set statistics time on;
*/

--����� ������� �������
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
2. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ��� 
(�� 2 ����� ���������� �������� � ������ ������)
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
Select '2016'			as '���'
      ,CTE.mm			as '�����'
	  ,si.StockItemName as '�������� ������'
	  ,CTE.iCount		as '����������'
  from CTE
 inner join Warehouse.StockItems si
    on si.StockItemID = CTE.StockItemID
 where DRank <= 2;

/*
3. ������� ����� ��������
���������� �� ������� �������, � ����� ����� ������ ������� �� ������, ��������, ����� � ����
������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
���������� ����� ���������� ������� � �������� ����� � ���� �� �������
���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
���������� �� ������ � ��� �� �������� ����������� (�� �����)
�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
��� ���� ������ �� ����� ������ ������ ��� ������������� �������
*/

Select si.StockItemID																	as 'ID'
      ,si.StockItemName																	as '�������� ������'
	  ,si.Brand																			as '�����'
	  ,si.UnitPrice																		as '����'
	  ,DENSE_RANK() OVER (order by substring(si.StockItemName,1,1) asc)					as 'DRank_bukv' --������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
	  ,Count(si.StockItemID) OVER ()													as '����� �-�� �������' --���������� ����� ���������� ������� � �������� ����� � ���� �� �������
	  ,Count(si.StockItemID) OVER (partition by substring(si.StockItemName,1,1))		as '���. �-�� ���. �� ����. ���.' --���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
	  ,Lead(si.StockItemID) OVER (order by si.StockItemName asc)						as '���� ID' --���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
	  ,Lag(si.StockItemID) OVER (order by si.StockItemName asc)							as '���� ID' --���������� �� ������ � ��� �� �������� ����������� (�� �����)
	  ,isnull(Lag(si.StockItemName,2) OVER (order by si.StockItemName asc),'No items')	as '���� 2 ��� �����' --�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
	  ,NTILE(30) OVER (order by si.TypicalWeightPerUnit)								as '30 �����' --����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
  from Warehouse.StockItems si
 order by si.StockItemName;

/*
4. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������
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
Select CTE.SalespersonPersonID	as 'ID ��������'
      ,ps.FullName				as '��� ��������'
	  ,CTE.CustomerID			as 'ID ����������'
	  ,c.CustomerName			as '��� ����������'
	  ,CTE.OrderDate			as '���� �������'
	  ,CTE.oSum					as '����� ������'
  from CTE
 inner join Application.People ps
    on ps.PersonID = CTE.SalespersonPersonID
 inner join Sales.Customers c
    on c.CustomerID = CTE.CustomerID
 where CTE.DRank = 1;
  
/*
5. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
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
Select CTE.CustomerID	as 'ID ����������'
      ,c.CustomerName	as '��� ����������'
	  ,CTE.StockItemID	as 'ID ������'
	  ,si.StockItemName	as '�������� ������'
	  ,CTE.UnitPrice	as '���� ������'
	  ,CTE.OrderDate	as '���� ������'
  from CTE
 inner join Warehouse.StockItems si
    on si.StockItemID = CTE.StockItemID
 inner join Sales.Customers c
    on c.CustomerID = CTE.CustomerID
 where CTE.DRank <= 2
 order by CTE.CustomerID;

/*
Bonus �� ���������� ����
�������� ������, ������� �������� 10 ��������, ������� ������� ������ 30 ������� � ��������� ����� ��� �� ������� ������ 2016
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