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
                           ,Brief			char(20)
						   ,Name			char(160)
                           );

Create table bi.Client (ClientID		int primary key
                       ,ClientTypeID	int not null foreign key references bi.ClientType(ClientTypeID)
					   ,Brief			char(25)
					   ,FirstName		char(160)
                       ,LastName		char(160)
                       ,MiddleName		char(160)
				   	   ,Sex				int
					   ,BirthDate		smalldatetime
					   ,INN				char(20)

                        );

Create table bi.ClientDocType (ClientDocTypeID	int primary key
                              ,Brief			char(20)
						      ,Name				char(160)
                              );

Create table bi.ClientDoc (ClientDocID		int primary key
					      ,ClientID			int not null foreign key references bi.Client(ClientID)
						  ,ClientDocTypeID	int not null foreign key references bi.ClientDocType(ClientDocTypeID)
                          ,DocNumber		char(20)
                          ,DocSeries		char(20)
					      ,Code				char(20)
						  ,DateStart		smalldatetime
						  ,DateEnd			smalldatetime
						  ,DocPlace			char(255)
						  ,Active			int
                          );

Create table bi.ContactType (ContactTypeID	int primary key
                            ,Brief			char(20)
						    ,Name			char(160)
                            );

Create table bi.ClientContact (ClientContactID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,ContactTypeID	int not null foreign key references bi.ContactType(ContactTypeID)
							  ,Value			char(30)
							  ,Active			int
                               );

Create table bi.AddressType (AddressTypeID	int primary key
                            ,Brief			char(20)
						    ,Name			char(160)
                            );

Create table bi.ClientAddress (ClientAddressID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,AddressTypeID	int not null foreign key references bi.AddressType(AddressTypeID)
							  ,Value			char(200)
							  ,Active			int
                               );

Create table bi.Balance (BalanceID	int primary key
                        ,Brief		char(20)
						,Name		char(160)
                        );

Create table bi.Account (AccountID	int primary key
                        ,ClientID	int not null foreign key references bi.Client(ClientID)
						,BankID		int not null foreign key references bi.Client(ClientID)
						,Number		char(20)
						,Name		char(100)
						,Currency	int
						,DateStart	smalldatetime
						,DateEnd	smalldatetime
						,Active		int
						,BalanceID	int not null foreign key references bi.Balance(BalanceID)
                         );

Create table bi.Rest (RestID	int primary key
                     ,AccountID	int not null foreign key references bi.Account(AccountID)
					 ,BalanceID	int not null foreign key references bi.Balance(BalanceID)
					 ,Amount	money
					 ,Date		smalldatetime
                     );

Create table bi.Instrument (InstrumentID	int primary key
                           ,Brief			char(20)
						   ,Name			char(160)
                           );

Create table bi.State (StateID	int primary key
                      ,Brief	char(20)
				      ,Name		char(160)
                      );

Create table bi.BankProduct (BankProductID	int primary key
                            ,Brief			char(20)
				            ,Name			char(160)
                            );

Create table bi.ContractCredit (ContractCreditID	int primary key
							   ,InstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
                               ,ClientID			int not null foreign key references bi.Client(ClientID)
                               ,BankProductID		int not null foreign key references bi.BankProduct(BankProductID)
							   ,StateID				int not null foreign key references bi.State(StateID)
							   ,BankID              int not null foreign key references bi.Client(ClientID)
							   ,Number              char(40)
					           ,Currency			int
					           ,CreditAmount		money
					           ,CreditDateFrom		smalldatetime
					           ,CreditDateTo		smalldatetime
							   ,PaymentDay			int
							   ,Active				int
                               );
		   
Create table bi.Deposit (DepositID		int primary key
						,InstrumentID	int not null foreign key references bi.Instrument(InstrumentID)
                        ,ClientID		int not null foreign key references bi.Client(ClientID)
					    ,BankID         int not null foreign key references bi.Client(ClientID)
						,StateID		int not null foreign key references bi.State(StateID)
					    ,Currency		int
						,Number         char(40)
					    ,DepAmount		money
					    ,DepDateFrom	smalldatetime
					    ,DepDateTo		smalldatetime
						,Active			int
                        );

Create table bi.InterestType (InterestTypeID	int primary key
                             ,Brief			char(20)
				             ,Name			char(160)
                             );

Create table bi.Interest (InterestID		int primary key
                         ,IstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
						 ,InterestTypeID	int not null foreign key references bi.InterestType(InterestTypeID)
						 ,ObjectID			int --(ContractCredit.ContractCreditID, Deposit.DepositID)
				         ,Value				money
						 ,DateStart			smalldatetime
						 ,DateEnd			smalldatetime
						 ,Active			int
                         );

