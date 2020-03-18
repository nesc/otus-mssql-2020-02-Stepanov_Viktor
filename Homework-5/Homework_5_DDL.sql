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
--База данных предназначена для агрегации, подсчета и хранения данных различных систем финансовой организации.
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

--Позжа планируется добавить другие схемы для загрузки данных из разных систем
Create schema bi;
GO

--Таблица Типы клиентов
Create table bi.ClientType (ClientTypeID	int primary key
                           ,Brief			varchar(20)  --Сокращенное наименовние
						   ,Name			varchar(160) --Полное наименование
                           );
						   
create index Index_Brief on bi.ClientType(Brief);

--Таблица Клиенты
Create table bi.Client (ClientID		int primary key
                       ,ClientTypeID	int not null foreign key references bi.ClientType(ClientTypeID)
					   ,Brief			varchar(25)   --Сокращенное наименовние
					   ,FirstName		varchar(160)  --Имя
                       ,LastName		varchar(160)  --Фамилия
                       ,MiddleName		varchar(160)  --Отчество
				   	   ,Sex				int			  --Пол
					   ,BirthDate		smalldatetime --Дата рождения
					   ,INN				varchar(20)   --ИНН
                        );
						   
create index Index_Type_Brief on bi.Client(ClientTypeID, Brief);
create index Index_INN on bi.Client(INN);

--Таблица Типы документов клиентов (Паспорт, вид на жительство, Иностранный паспорт и т.п.)
Create table bi.ClientDocType (ClientDocTypeID	int primary key
                              ,Brief			varchar(20)  --Сокращенное наименовние
						      ,Name				varchar(160) --Полное наименование
                              );
						   
create index Index_Brief on bi.ClientDocType(Brief);

--Таблица Документы клиентов (Паспорт, вид на жительство, Иностранный паспорт и т.п.)
Create table bi.ClientDoc (ClientDocID		int primary key
					      ,ClientID			int not null foreign key references bi.Client(ClientID)
						  ,ClientDocTypeID	int not null foreign key references bi.ClientDocType(ClientDocTypeID)
                          ,DocNumber		varchar(20)   --Номер документа
                          ,DocSeries		varchar(20)   --Серия документа
					      ,Code				varchar(20)   --Код подразделения (Для паспорта РФ)
						  ,DateStart		smalldatetime --Дата выдачи
						  ,DateEnd			smalldatetime --Дата окончания
						  ,DocPlace			varchar(255)  --Место выдачи
						  ,Active			int           --Действует или нет
                          );
						   
create index Index_ClientID on bi.ClientDoc(ClientID);
create index Index_ClientDocTypeID on bi.ClientDoc(ClientDocTypeID);
create index Index_DocNumber_DocSeries on bi.ClientDoc(DocNumber,DocSeries);

--Таблица Типы контактов
Create table bi.ContactType (ContactTypeID	int primary key
                            ,Brief			varchar(20)  --Сокращенное наименовние
						    ,Name			varchar(160) --Полное наименование
                            );
						   
create index Index_Brief on bi.ContactType(Brief);

--Таблица Контакты клиентов
Create table bi.ClientContact (ClientContactID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,ContactTypeID	int not null foreign key references bi.ContactType(ContactTypeID)
							  ,Value			varchar(30) --Номер телефона, адрес email и т.п.
							  ,Active			int         --Действует или нет
                               );
						   
create index Index_ClientID on bi.ClientContact(ClientID);
create index Index_ContactTypeID on bi.ClientContact(ContactTypeID);

--Таблица Типы адресов (Адрес регистрации, адрес пребывания и т.п.)
Create table bi.AddressType (AddressTypeID	int primary key
                            ,Brief			varchar(20)  --Сокращенное наименовние
						    ,Name			varchar(160) --Полное наименование
                            );
						   
create index Index_Brief on bi.AddressType(Brief);

--Таблица Адреса клиентов
Create table bi.ClientAddress (ClientAddressID	int primary key
                              ,ClientID			int not null foreign key references bi.Client(ClientID)
							  ,AddressTypeID	int not null foreign key references bi.AddressType(AddressTypeID)
							  ,Value			varchar(200) --Строка адреса
							  ,Active			int          --Действует или нет
                               );
						   
create index Index_ClientID on bi.ClientAddress(ClientID);
create index Index_AddressTypeID on bi.ClientAddress(AddressTypeID);

--Таблица Области учета (В финансовых организациях используется план счетов с областями учета: А, В, К и т.п.)
Create table bi.Balance (BalanceID	int primary key
                        ,Brief		varchar(20)  --Сокращенное наименовние
						,Name		varchar(160) --Полное наименование
                        );
						   
create index Index_Brief on bi.Balance(Brief);

--Таблица Счета (Все счета из плана счетов в том числе: А-4, 4-08, 4-08-17, 40817810400000000001)
Create table bi.Account (AccountID	int primary key
                        ,ClientID	int not null foreign key references bi.Client(ClientID)
						,BankID		int not null foreign key references bi.Client(ClientID)
						,BalanceID	int not null foreign key references bi.Balance(BalanceID)
						,Number		varchar(20)   --Номер счета
						,Name		varchar(100)  --Наименование счета
						,Currency	int           --Валюта счета
						,DateStart	smalldatetime --Дата открытия
						,DateEnd	smalldatetime --Дата закрытия
						,Active		int           --Действует или нет
                         );
						   
create index Index_ClientID on bi.Account(ClientID);
create index Index_Number on bi.Account(Number);

--Таблица Остатки по счетам в разрезе даты
Create table bi.Rest (RestID	int primary key
                     ,AccountID	int not null foreign key references bi.Account(AccountID)
					 ,BalanceID	int not null foreign key references bi.Balance(BalanceID)
					 ,Amount	money         --Сумма остатка
					 ,Date		smalldatetime --Дата остатка
                     );
						   
create index Index_AccountID_Date on bi.Rest(AccountID, Date);

--Таблица Финансовые операции (Системные типы в системах)
Create table bi.Instrument (InstrumentID	int primary key
                           ,Brief			varchar(20)  --Сокращенное наименовние
						   ,Name			varchar(160) --Полное наименование
                           );
						   
create index Index_Brief on bi.Instrument(Brief);

--Таблица Состояния (Документов, договоров и т.п.)
Create table bi.State (StateID			int primary key
					  ,InstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
                      ,Brief			varchar(20)  --Сокращенное наименовние
				      ,Name				varchar(160) --Полное наименование
                      );
						   
create index Index_Brief on bi.State(Brief);

--Таблица Банковские продукты (Таблица относится к кредитным договорам)
Create table bi.BankProduct (BankProductID	int primary key
                            ,Brief			varchar(20)  --Сокращенное наименовние
				            ,Name			varchar(160) --Полное наименование
                            );
						   
create index Index_Brief on bi.BankProduct(Brief);

--Таблица Кредиты
Create table bi.ContractCredit (ContractCreditID	int primary key
							   ,InstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
                               ,ClientID			int not null foreign key references bi.Client(ClientID)
                               ,BankProductID		int not null foreign key references bi.BankProduct(BankProductID)
							   ,StateID				int not null foreign key references bi.State(StateID)
							   ,BankID              int not null foreign key references bi.Client(ClientID)
							   ,Number              varchar(40)   --Номер кредитного договора
					           ,Currency			int           --Валюта в которой предоставлен договор
					           ,CreditAmount		money         --Сумма кредита
					           ,CreditDateFrom		smalldatetime --Дата выдачи
					           ,CreditDateTo		smalldatetime --Дата погашения
							   ,PaymentDay			int           --День платежа (1, 15, 28 и т.п.)
							   ,Active				int           --Действует или нет
                               );
						   
create index Index_ClientID on bi.ContractCredit(ClientID);
create index Index_InstrumentID_StateID on bi.ContractCredit(InstrumentID, StateID);
create index Index_BankProductID on bi.ContractCredit(BankProductID);
		   
--Таблица Депозиты
Create table bi.Deposit (DepositID		int primary key
						,InstrumentID	int not null foreign key references bi.Instrument(InstrumentID)
                        ,ClientID		int not null foreign key references bi.Client(ClientID)
					    ,BankID         int not null foreign key references bi.Client(ClientID)
						,StateID		int not null foreign key references bi.State(StateID)
					    ,Currency		int           --Валюта в которой предоставлен договор
						,Number         varchar(40)   --Номер депозитного договора
					    ,DepAmount		money         --Сумма депозита
					    ,DepDateFrom	smalldatetime --Дата открытия
					    ,DepDateTo		smalldatetime --Дата завершения
						,Active			int           --Действует или нет
                        );
						   
create index Index_ClientID on bi.Deposit(ClientID);
create index Index_InstrumentID_StateID on bi.Deposit(InstrumentID, StateID);

--Таблица Типы процентных ставок
Create table bi.InterestType (InterestTypeID	int primary key
                             ,Brief			varchar(20)  --Сокращенное наименовние
				             ,Name			varchar(160) --Полное наименование
                             );
						   
create index Index_Brief on bi.InterestType(Brief);

--Таблица Процентные ставки в разрезе дат
Create table bi.Interest (InterestID		int primary key
                         ,IstrumentID		int not null foreign key references bi.Instrument(InstrumentID)
						 ,InterestTypeID	int not null foreign key references bi.InterestType(InterestTypeID)
						 ,ObjectID			int           --(ContractCredit.ContractCreditID, Deposit.DepositID)
				         ,Value				money         --Сумма процентной ставки
						 ,DateStart			smalldatetime --Дата начала действия ставки
						 ,DateEnd			smalldatetime --Дата окончания действия ставки
						 ,Active			int           --Действует или нет
                         );
						   
create index Index_ObjectID on bi.Interest(ObjectID);
create index Index_ObjectID_InterestTypeID on bi.Interest(ObjectID, InterestTypeID);

