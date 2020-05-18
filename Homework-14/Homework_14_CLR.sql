--1) Взять готовую dll, подключить ее и продемонстрировать использование.
--Например, https://sqlsharp.com
--Скачал, поставил. Попробуем Util_ToWords

Select SQL#.Util_ToWords(6950.99);
--Результат:
--Six Million, Nine Hundred Fifty Thousand, Ninety Nine



--2) Взять готовые исходники из какой-нибудь статьи, скомпилировать, подключить dll, продемонстрировать использование.
--Например,
--https://habr.com/ru/post/88396/

exec sp_configure 'clr enabled', 1
go
exec sp_configure 'clr strict security', 0
go
reconfigure
go

CREATE ASSEMBLY CLRFunctions FROM 'C:\Users\DeoneFire\source\repos\SplitString\SplitString\bin\Debug\SplitString.dll'
go

CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME CLRFunctions.UserDefinedFunctions.SplitString

Select * from SplitStringCLR('1,2,34,5,6564,654,66,456,546,,,,,7',',');
--Результат:
--part	ID_ODER
--1		1
--2		2
--34	3
--5		4
--6564	5
--654	6
--66	7
--456	8
--546	9
--7		10



--3) Написать полностью свое (что-то одно)
--Свой вариант
--Бизнес функция. Функция, которая возвращает действителен паспорт на дату или нет.
--Входные параметры:
	--Дата рождения
	--Дата выдачи паспорта
	--Дата на которую требуется проверка
		--На выходе ответ текстом "Действует", Не действует

drop function dbo.CheckPasport
drop ASSEMBLY CLRFunctionsCheckPasport

CREATE ASSEMBLY CLRFunctionsCheckPasport FROM 'C:\Users\DeoneFire\source\repos\CheckPasportDate\CheckPasportDate\bin\Debug\CheckPasportDate.dll'
WITH PERMISSION_SET = UNSAFE;
go

CREATE FUNCTION [dbo].[CheckPasport] (@DateB [datetime], @DateP [datetime], @DateC [datetime])
RETURNS TABLE (string NVARCHAR(MAX))
AS EXTERNAL NAME [CLRFunctionsCheckPasport].[UserDefinedFunctions].[FillRow];
go

Select *
from [CheckPasport]('19890822', '20090930', '20200512')
