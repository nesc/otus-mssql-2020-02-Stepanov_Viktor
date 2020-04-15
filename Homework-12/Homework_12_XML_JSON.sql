/*
1. ��������� ������ �� ����� StockItems.xml � ������� Warehouse.StockItems.
������������ ������ � ������� ��������, ������������� �������� ������������ ������ �� ���� StockItemName).
���� StockItems.xml � ������ ��������.
*/

Declare @xml		XML
       ,@docHandle	int;

Set @xml = ( 
            Select * 
		    from OPENROWSET (BULK 'C:\Load\StockItems.xml', SINGLE_BLOB) as d
           );

exec sp_xml_preparedocument @docHandle OUTPUT, @xml;

Merge Warehouse.StockItems as Target
Using (
Select x.SupplierID
      ,x.UnitPackageID
	  ,x.OuterPackageID
	  ,x.QuantityPerOuter
	  ,x.TypicalWeightPerUnit
	  ,x.LeadTimeDays
	  ,x.IsChillerStock
	  ,x.TaxRate
	  ,x.UnitPrice
	  ,x.StockItemName
 from OPENXML(@docHandle, N'/StockItems/Item', 3)
 with ( 
	[SupplierID]			int 'SupplierID',
	[UnitPackageID]			int 'Package/UnitPackageID',
	[OuterPackageID]		int 'Package/OuterPackageID',
	[QuantityPerOuter]		int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit]	decimal(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays]			int 'LeadTimeDays',
	[IsChillerStock]		bit 'IsChillerStock',
	[TaxRate]				decimal(18,3) 'TaxRate',
	[UnitPrice]				decimal(18,2) 'UnitPrice',
	[StockItemName]			nvarchar(200) '@Name') as x
) as source (SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, StockItemName) 
  on (target.StockItemName = source.StockItemName) 
  when matched 
  then update set SupplierID			= source.SupplierID
                 ,UnitPackageID			= source.UnitPackageID
                 ,OuterPackageID		= source.OuterPackageID
                 ,QuantityPerOuter		= source.QuantityPerOuter
                 ,TypicalWeightPerUnit  = source.TypicalWeightPerUnit 
                 ,LeadTimeDays			= source.LeadTimeDays
                 ,IsChillerStock		= source.IsChillerStock
                 ,TaxRate				= source.TaxRate
                 ,UnitPrice				= source.UnitPrice
                 ,StockItemName			= source.StockItemName
  when not matched
  then Insert (SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, StockItemName, LastEditedBy)
       values (source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit , source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, source.StockItemName
	          ,1 --������� ��-�� constraint. ID ������ ��������� ������ - "Data Conversion Only"
			  )
output $action, deleted.*, inserted.*;

exec sp_xml_removedocument @docHandle;

--2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml

EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE

Select s.StockItemName			as [@Name]
	  ,s.SupplierID				as [SupplierID]
      ,s.UnitPackageID			as [Package/UnitPackageID]
	  ,s.OuterPackageID			as [Package/OuterPackageID]
	  ,s.QuantityPerOuter		as [Package/QuantityPerOuter]
	  ,s.TypicalWeightPerUnit	as [Package/TypicalWeightPerUnit]
	  ,s.LeadTimeDays			as [LeadTimeDays]
	  ,s.IsChillerStock			as [IsChillerStock]
	  ,s.TaxRate				as [TaxRate]
	  ,s.UnitPrice				as [UnitPrice]
  from Warehouse.StockItems s
FOR XML PATH('Item'), ROOT('StockItems')

EXEC xp_cmdshell 'bcp "use WideWorldImporters Select s.StockItemName as [@Name] ,s.SupplierID as [SupplierID] ,s.UnitPackageID as [Package/UnitPackageID] ,s.OuterPackageID as [Package/OuterPackageID] ,s.QuantityPerOuter as [Package/QuantityPerOuter] ,s.TypicalWeightPerUnit as [Package/TypicalWeightPerUnit] ,s.LeadTimeDays as [LeadTimeDays] ,s.IsChillerStock as [IsChillerStock] ,s.TaxRate as [TaxRate] ,s.UnitPrice as [UnitPrice] from Warehouse.StockItems s FOR XML PATH(''Item''), ROOT(''StockItems'')" queryout "C:\Load\Out\StockItems.xml" -T -c -S LAPTOP-MNSV0V7P\SQL2017'
--���� ��������� � ����� � �������� �������

/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
*/

Select StockItemID
      ,StockItemName
	  ,JSON_VALUE(CustomFields,'$.CountryOfManufacture')
	  ,JSON_VALUE(CustomFields,'$.Tags[0]')
  from Warehouse.StockItems

/*
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������:
- StockItemID
- StockItemName
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����
*/

Select s.StockItemID
      ,s.StockItemName
	  ,Replace(Replace(Replace(JSON_QUERY(CustomFields, '$.Tags'),'[',''),']',''),'"','')
  from Warehouse.StockItems s
 Cross apply STRING_SPLIT((Replace(Replace(Replace(JSON_QUERY(CustomFields, '$.Tags'),'[',''),']',''),'"','')), ',') j
 where j.value = 'Vintage'
