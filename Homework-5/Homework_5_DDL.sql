/*
Краткое описание проекта:
---------------------------------------------------------------------------------------------------------------
Необходимо разработать базу данных для хранения и обработки данных бизнес подразделений финансовой организации. 
Требуется хранить информацию:
- о клиентах
- контактной информации
- адресах
- счетах
- остатках денежных средств
- кредитных договорах
- договоров вклада
- прочей информации, которая миожет добавиться в ходе реализации проекта

Реализовать процедуры: 
- по обработке и нормализации загружаемых данных
- по получению остатков
- по получению сводной информации о клиенте на дату
- прочий анализ внутри функционала БД

Реализовать выгрузку и отправку простых отчетных форм на email средствами БД

Позже задание проекта будет изменено в связи с получением новых знаний в ходе обучения
---------------------------------------------------------------------------------------------------------------

Нужно используя операторы DDL создать:
1. 3-4 основные таблицы для своего проекта.
2. Первичные и внешние ключи для всех созданных таблиц
3. 1-2 индекса на таблицы
*/


--Создадим схему bi (Business Intelligence)
use master;
Create database BusinessReports
 Containment = none
 on Primary (Name		= BusinessReports
            ,filename	= N'D:\OTUS\Project\DB\BusinessReports.mdf'
			,Size		= 8MB
			,MaxSize	= Unlimited
			,FileGrowth	= 65536KB
			)
 Log on (Name		= BusinessReports_log
        ,FileName	= N'D:\OTUS\Project\DB\BusinessReports.ldf'
		,Size		= 8MB
		,MaxSize	= Unlimited
		,FileGrowth	= 65536KB
		)
GO

use BusinessReports;
GO

Create schema bi;
GO

Create table bi.ClientType (ClientTypeID	int primary key
                           ,Brief			varchar(20)
						   ,Name			varchar(160)
                           );
						   
create index Index_Brief on bi.ClientType(Brief);

Create table bi.Client (ClientID		int primary key
                       ,ClientTypeID	int not null foreign key references bi.ClientType(ClientTypeID)
					   ,Brief			varchar(25)
					   ,FirstName		varchar(160)
                       ,LastName		varchar(160)
                       ,MiddleName		varchar(160)
				   	   ,Sex				int
					   ,BirthDate		smalldatetime
					   ,INN				varchar(20)
                        );
						   
create index Index_Type_Brief on bi.Client(ClientTypeID, Brief);
create index Index_INN on bi.Client(INN);

Create table bi.ClientDocType (ClientDocTypeID	int primary key
                              ,Brief			varchar(20)
						      ,Name				varchar(160)
                              );
						   
create index Index_Brief on bi.ClientDocType(Brief);

Create table bi.ClientDoc (ClientDocID		int primary key
					      ,ClientID			int not null foreign key references bi.Client(ClientID)
						  ,ClientDocTypeID	int not null foreign key references bi.ClientDocType(ClientDocTypeID)
                          ,DocNumber		varchar(20)
                          ,DocSeries		varchar(20)
					      ,Code				varchar(20)
						  ,DateStart		smalldatetime
						  ,DateEnd			smalldatetime
						  ,DocPlace			varchar(255)
						  ,Active			int
                          );
						   
create index Index_ClientID on bi.ClientDoc(ClientID);
create index Index_ClientDocTypeID on bi.ClientDoc(ClientDocTypeID);
create index Index_DocNumber_DocSeries on bi.ClientDoc(DocNumber,DocSeries);

Create table bi.ContactType (ContactTypeID	int primary key
                            ,Brief			varchar(20)
						    ,Name			varchar(160)
                            );
						   
create index Index_Brief on bi.ContactType(Brief);

Create table bi.ClientContact (ClientContactID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,ContactTypeID	int not null foreign key references bi.ContactType(ContactTypeID)
							  ,Value			varchar(30)
							  ,Active			int
                               );
						   
create index Index_ClientID on bi.ClientContact(ClientID);
create index Index_ContactTypeID on bi.ClientContact(ContactTypeID);

Create table bi.AddressType (AddressTypeID	int primary key
                            ,Brief			varchar(20)
						    ,Name			varchar(160)
                            );
						   
create index Index_Brief on bi.AddressType(Brief);

Create table bi.ClientAddress (ClientAddressID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,AddressTypeID	int not null foreign key references bi.AddressType(AddressTypeID)
							  ,Value			varchar(200)
							  ,Active			int
                               );
						   
create index Index_ClientID on bi.ClientAddress(ClientID);
create index Index_AddressTypeID on bi.ClientAddress(AddressTypeID);

Create table bi.Balance (BalanceID	int primary key
                        ,Brief		varchar(20)
						,Name		varchar(160)
                        );
						   
create index Index_Brief on bi.Balance(Brief);

Create table bi.Account (AccountID	int primary key
                        ,ClientID	int not null foreign key references bi.Client(ClientID)
						,BankID		int not null foreign key references bi.Client(ClientID)
						,BalanceID	int not null foreign key references bi.Balance(BalanceID)
						,Number		varchar(20)
						,Name		varchar(100)
						,Currency	int
						,DateStart	smalldatetime
						,DateEnd	smalldatetime
						,Active		int
                         );
						   
create index Index_ClientID on bi.Account(ClientID);
create index Index_Number on bi.Account(Number);

Create table bi.Rest (RestID	int primary key
                     ,AccountID	int not null foreign key references bi.Account(AccountID)
					 ,BalanceID	int not null foreign key references bi.Balance(BalanceID)
					 ,Amount	money
					 ,Date		smalldatetime
                     );
						   
create index Index_AccountID_Date on bi.Rest(AccountID, Date);

Create table bi.Instrument (InstrumentID	int primary key
                           ,Brief			varchar(20)
						   ,Name			varchar(160)
                           );
						   
create index Index_Brief on bi.Instrument(Brief);

Create table bi.State (StateID			int primary key
					  ,InstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
                      ,Brief			varchar(20)
				      ,Name				varchar(160)
                      );
						   
create index Index_Brief on bi.State(Brief);

Create table bi.BankProduct (BankProductID	int primary key
                            ,Brief			varchar(20)
				            ,Name			varchar(160)
                            );
						   
create index Index_Brief on bi.BankProduct(Brief);

Create table bi.ContractCredit (ContractCreditID	int primary key
							   ,InstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
                               ,ClientID			int not null foreign key references bi.Client(ClientID)
                               ,BankProductID		int not null foreign key references bi.BankProduct(BankProductID)
							   ,StateID				int not null foreign key references bi.State(StateID)
							   ,BankID              int not null foreign key references bi.Client(ClientID)
							   ,Number              varchar(40)
					           ,Currency			int
					           ,CreditAmount		money
					           ,CreditDateFrom		smalldatetime
					           ,CreditDateTo		smalldatetime
							   ,PaymentDay			int
							   ,Active				int
                               );
						   
create index Index_ClientID on bi.ContractCredit(ClientID);
create index Index_InstrumentID_StateID on bi.ContractCredit(InstrumentID, StateID);
create index Index_BankProductID on bi.ContractCredit(BankProductID);
		   
Create table bi.Deposit (DepositID		int primary key
						,InstrumentID	int not null foreign key references bi.Instrument(InstrumentID)
                        ,ClientID		int not null foreign key references bi.Client(ClientID)
					    ,BankID         int not null foreign key references bi.Client(ClientID)
						,StateID		int not null foreign key references bi.State(StateID)
					    ,Currency		int
						,Number         varchar(40)
					    ,DepAmount		money
					    ,DepDateFrom	smalldatetime
					    ,DepDateTo		smalldatetime
						,Active			int
                        );
						   
create index Index_ClientID on bi.Deposit(ClientID);
create index Index_InstrumentID_StateID on bi.Deposit(InstrumentID, StateID);

Create table bi.InterestType (InterestTypeID	int primary key
                             ,Brief			varchar(20)
				             ,Name			varchar(160)
                             );
						   
create index Index_Brief on bi.InterestType(Brief);

Create table bi.Interest (InterestID		int primary key
                         ,IstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
						 ,InterestTypeID	int not null foreign key references bi.InterestType(InterestTypeID)
						 ,ObjectID			int --(ContractCredit.ContractCreditID, Deposit.DepositID)
				         ,Value				money
						 ,DateStart			smalldatetime
						 ,DateEnd			smalldatetime
						 ,Active			int
                         );
						   
create index Index_ObjectID on bi.Interest(ObjectID);
create index Index_ObjectID_InterestTypeID on bi.Interest(ObjectID, InterestTypeID);

