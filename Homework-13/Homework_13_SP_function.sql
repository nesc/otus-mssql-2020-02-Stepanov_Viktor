--1) �������� ������� ������������ ������� � ���������� ������ �������.

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
2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
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

--3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
--������ ������ ����������� 2 ������� � ������ ��

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

--1. ������ ������� ������� � ��������� � ����������� �������
--2. ����� ����������� �� 50% � 50%
--3. ��� ���������. ����� ����� ����� ������� ���������� ������ ��������� � �������, �� � ������� �� ���� �� �������.



--4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.

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

--�� ���� ����������, � �������� ������� ��� ��������������
--5) ����� ������� �������� ����� � ������.

--�� ��� ������ ��� ���� ������� ������� � ����������� � ���� �������� ������� ���������� ������ �������� �� ��������� READ COMMITTED
--����� ��� ��������� ��������� ������ � �� ����������� READ UNCOMMITTED ������ ��� ��� ������� � ��������� ������� �� ������ ������� � ����������� ����� ������������.
--������� ����� ������� ������� �������� ������ ��� � ������ ������.

--��� ���� �� � ������� ��� ��������� ����������� �� ��������� ������, ����� � �� ��������� REPEATABLE READ

--������������� SNAPSHOT ISOLATION � SERIALIZABLE �� ��� ������ ������. ���� ����� �������� � ����� ������ ������� ��� ����������� ����. ��� ���� ���������� ������ ���� ������� � ����������������