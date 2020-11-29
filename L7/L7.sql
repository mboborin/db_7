/* Point 1
	Вывожу значения полей 
		[BusinessEntityID], 
		[Name], 
		[AccountNumber]
	из таблицы [Purchasing].[Vendor] в виде xml, сохраненного в переменную.
*/
CREATE PROCEDURE [dbo].ToXML @xml XML
AS
BEGIN
    IF object_id('tempdb.#resultTable') IS NULL
    BEGIN
        CREATE TABLE #resultTable
        (
            [BusinessEntityID] int,
            [Name]             nvarchar(50),
            [AccountNumber]    nvarchar(15)
        )
    END;

    INSERT #resultTable
		SELECT [BusinessEntityID] = Node.Data.value('(ID)[1]', 'INT'),
			   [Name] = Node.Data.value('(Name)[1]', 'NAME'),
			   [AccountNumber] = Node.Data.value('(AccountNumber)[1]', 'AccountNumber')
		FROM @xml.nodes('/Vendors/Vendor') Node(Data)

    SELECT * FROM #resultTable;
END;
GO

/* Point 2
	Создаю хранимую процедуру, возвращающую таблицу, заполненную из xml переменной представленного вида. 
	Вызваю эту процедуру для заполненной на первом шаге переменной.
*/

CREATE PROCEDURE [dbo].GetResultTable
AS
BEGIN
    DECLARE @vendorsFromXML XML;
    SELECT @vendorsFromXML = (
        SELECT 
			[BusinessEntityID] AS ID, 
			[Name], 
			[AccountNumber]
		FROM [Purchasing].[Vendor]
		FOR XML 
			RAW ('Vendor'), 
			TYPE, 
			ELEMENTS, 
			ROOT ('Vendors')
    );
    EXEC [dbo].ToXML @vendorsFromXML;
END;
GO

EXEC GetResultTable;
