--1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers

Insert Sales.Customers (
CustomerName,
BillToCustomerID,
CustomerCategoryID,
PrimaryContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
WebsiteURL,
DeliveryAddressLine1,
DeliveryPostalCode,
PostalAddressLine1,
PostalPostalCode,
LastEditedBy
)
values 
('Cristina Agilera' , 1061, 5, 3261, 3, 29391, 29391, '20200301', 0, 0, 0, 7 , '(929)555-6644', '(929)555-6644', 'http://www.microsoft.com/', 'Shop 66', 90170, 'PO Box 8112', 90170, 1),
('Antonio Banderas' , 1060, 5, 3260, 3, 22090, 22090, '20200202', 0, 0, 0, 7 , '(495)111-2441', '(495)111-2441', 'http://www.microsoft.com/', 'Shop 50', 90755, 'PO Box 804' , 90755, 1),
('Marko Polo'       , 1059, 5, 3259, 3, 31564, 31564, '20200115', 0, 0, 0, 7 , '(499)124-6422', '(499)124-6422', 'http://www.microsoft.com/', 'Shop 15', 90243, 'PO Box 13'  , 90243, 1),
('Augestini Bernini', 1058, 5, 3258, 3, 19507, 19507, '20200312', 0, 0, 0, 7 , '(916)876-6874', '(916)876-6874', 'http://www.microsoft.com/', 'Shop 36', 90069, 'PO Box 7789', 90069, 1),
('Natalia Koroleva' , 1057, 5, 3257, 3, 19374, 19374, '20200203', 0, 0, 0, 7 , '(905)078-1642', '(905)078-1642', 'http://www.microsoft.com/', 'Shop 13', 90650, 'PO Box 9529', 90650, 1)

--2. удалите 1 запись из Customers, которая была вами добавлена

Delete Sales.Customers where CustomerName = 'Cristina Agilera'

--3. изменить одну запись, из добавленных через UPDATE

Update Sales.Customers set CustomerName = 'Cristiano Ranaldo' where CustomerName = 'Marko Polo'

--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть

Drop table if exists #My
GO

Create table #My (CustomerName					nvarchar(200) collate Latin1_General_100_CI_AS
				 ,BillToCustomerID				int
				 ,CustomerCategoryID			int
				 ,PrimaryContactPersonID		int
				 ,DeliveryMethodID				int
				 ,DeliveryCityID				int
				 ,PostalCityID					int
				 ,AccountOpenedDate				date
				 ,StandardDiscountPercentage	decimal
				 ,IsStatementSent				bit
				 ,IsOnCreditHold				bit
				 ,PaymentDays					int
				 ,PhoneNumber					nvarchar(40) collate Latin1_General_100_CI_AS
				 ,FaxNumber						nvarchar(40) collate Latin1_General_100_CI_AS
				 ,WebsiteURL					nvarchar(512) collate Latin1_General_100_CI_AS
				 ,DeliveryAddressLine1			nvarchar(120) collate Latin1_General_100_CI_AS
				 ,DeliveryPostalCode			nvarchar(20) collate Latin1_General_100_CI_AS
				 ,PostalAddressLine1			nvarchar(120) collate Latin1_General_100_CI_AS
				 ,PostalPostalCode				nvarchar(20) collate Latin1_General_100_CI_AS
				 ,LastEditedBy					int
				 );


Insert #My (
CustomerName,
BillToCustomerID,
CustomerCategoryID,
PrimaryContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
WebsiteURL,
DeliveryAddressLine1,
DeliveryPostalCode,
PostalAddressLine1,
PostalPostalCode,
LastEditedBy
)
values 
('Natalia Koroleva'    , 1057, 5, 3257, 3, 19374, 19374, '20200203', 0, 0, 0, 7 , '(905)078-1642', '(905)078-1642', 'http://www.microsoft.com/', 'Shop 13', 90650, 'PO Box 9529', 90650, 1),
('Konstantin Habensky' , 1056, 5, 3256, 3, 13333, 13333, '20200204', 0, 0, 0, 7 , '(276)875-0100', '(276)875-0100', 'http://www.microsoft.com/', 'Shop 88', 90137, 'PO Box 46'  , 90137, 1);

Merge Sales.Customers as Target
Using (
Select CustomerName					as CustomerName
	  ,BillToCustomerID				as BillToCustomerID
	  ,CustomerCategoryID			as CustomerCategoryID
	  ,PrimaryContactPersonID		as PrimaryContactPersonID
	  ,DeliveryMethodID				as DeliveryMethodID
	  ,DeliveryCityID				as DeliveryCityID
	  ,PostalCityID					as PostalCityID
	  ,AccountOpenedDate			as AccountOpenedDate
	  ,StandardDiscountPercentage	as StandardDiscountPercentage
	  ,IsStatementSent				as IsStatementSent
	  ,IsOnCreditHold				as IsOnCreditHold
	  ,PaymentDays					as PaymentDays
	  ,PhoneNumber					as PhoneNumber
	  ,FaxNumber					as FaxNumber
	  ,WebsiteURL					as WebsiteURL
	  ,DeliveryAddressLine1			as DeliveryAddressLine1
	  ,DeliveryPostalCode			as DeliveryPostalCode
	  ,PostalAddressLine1			as PostalAddressLine1
	  ,PostalPostalCode				as PostalPostalCode
	  ,LastEditedBy 				as LastEditedBy 
  from #My
) as source (CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy) 
  on (target.CustomerName = source.CustomerName) 
  when matched 
  then update set CustomerName = source.CustomerName 
				 ,BillToCustomerID = source.BillToCustomerID 
				 ,CustomerCategoryID = source.CustomerCategoryID 
				 ,PrimaryContactPersonID = source.PrimaryContactPersonID 
				 ,DeliveryMethodID = source.DeliveryMethodID 
				 ,DeliveryCityID = source.DeliveryCityID 
				 ,PostalCityID = source.PostalCityID 
				 ,AccountOpenedDate = source.AccountOpenedDate 
				 ,StandardDiscountPercentage = source.StandardDiscountPercentage 
				 ,IsStatementSent = source.IsStatementSent 
				 ,IsOnCreditHold = source.IsOnCreditHold 
				 ,PaymentDays = source.PaymentDays 
				 ,PhoneNumber = source.PhoneNumber 
				 ,FaxNumber = source.FaxNumber 
				 ,WebsiteURL = source.WebsiteURL 
				 ,DeliveryAddressLine1 = source.DeliveryAddressLine1 
				 ,DeliveryPostalCode = source.DeliveryPostalCode 
				 ,PostalAddressLine1 = source.PostalAddressLine1 
				 ,PostalPostalCode = source.PostalPostalCode 
				 ,LastEditedBy = source.LastEditedBy 
  when not matched
  then Insert (CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
       values (source.CustomerName, source.BillToCustomerID, source.CustomerCategoryID, source.PrimaryContactPersonID, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, source.AccountOpenedDate, source.StandardDiscountPercentage, source.IsStatementSent, source.IsOnCreditHold, source.PaymentDays, source.PhoneNumber, source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryPostalCode, source.PostalAddressLine1, source.PostalPostalCode, source.LastEditedBy)
OUTPUT $action, deleted.*, inserted.*;

--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

EXEC sp_configure 'show advanced options', 1;  
GO  

RECONFIGURE;  
GO  

EXEC sp_configure 'xp_cmdshell', 1;  
GO  

RECONFIGURE;  
GO  

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\BCP\InvoiceLines.txt" -T -w -t"@$#%$%*&*^" -S LAPTOP-MNSV0V7P\SQL2017';

Drop table if exists Sales.InvoiceLines_Load;

Create table Sales.InvoiceLines_Load (InvoiceLineID		int
                                     ,InvoiceID			int
									 ,StockItemID		int
									 ,Description		nvarchar(200)
									 ,PackageTypeID		int
									 ,Quantity			int
									 ,UnitPrice			decimal
									 ,TaxRate			decimal
									 ,TaxAmount			decimal
									 ,LineProfit		decimal
									 ,ExtendedPrice		decimal
									 ,LastEditedBy		int
									 ,LastEditedWhen	datetime2
									 );

BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_Load]
   FROM "D:\BCP\InvoiceLines.txt"
   WITH 
	 (
		BATCHSIZE = 1000, 
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = '@$#%$%*&*^',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK        
	  );
