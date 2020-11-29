/* Point 1
	Создаю scalar-valued функцию, 
		которая принимает в качестве входного параметра id заказа (Sales.SalesOrderHeader.SalesOrderID) и 
		возвращает максимальную цену продукта из заказа (Sales.SalesOrderDetail.UnitPrice).
*/
CREATE FUNCTION dbo.GetMaxPrice(@SalesOrderID [int])
    RETURNS Money
    WITH
        EXECUTE AS CALLER
AS
BEGIN
    DECLARE @res money;
    SET @res = (
			SELECT MAX(SOD.UnitPrice)
				FROM Sales.SalesOrderHeader AS SOH
				JOIN Sales.SalesOrderDetail AS SOD
					ON SOH.SalesOrderID = SOD.SalesOrderID
				WHERE @SalesOrderID = SOH.SalesOrderID);
    RETURN
        (@res);
END;
GO

/* Point 2
	Создаю inline table-valued функцию, 
		которая принимает в качестве входных параметров id продукта (Production.Product.ProductID) и 
		количество строк, которые необходимо вывести.

	Функция возвращает определенное количество инвентаризационных записей о продукте 
		с наибольшим его количеством (по Quantity) из Production.ProductInventory. 
	Функция возвращает только продукты, хранящиеся в отделе А (Production.ProductInventory.Shelf).
*/
CREATE FUNCTION dbo.GetCountProductsById(@ProductID [int], @RowCount [int])
    RETURNS TABLE
        AS RETURN
		(
			SELECT 
					ProductID,
					LocationID,
					Shelf,
					Bin,
					MaxQuantity,
					rowguid,
					ModifiedDate
			FROM (
				SELECT 
						ProductID,
						LocationID,
						Shelf,
						Bin,
						MAX(Quantity) OVER (PARTITION BY ProductID) AS MaxQuantity,
						RowGUID,
						ModifiedDate,
						ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS RowNumber
					FROM Production.ProductInventory
					WHERE ProductID = @ProductID AND Shelf = 'A'
				) AS Result
			WHERE RowNumber <= @RowCount
        );
GO

/* Point 3
	Вызываю функцию для каждого продукта, применив оператор CROSS APPLY.
	Вызываю функцию для каждого продукта, применив оператор OUTER APPLY.
*/
SELECT *
	FROM Production.Product AS P
	CROSS APPLY dbo.GetCountProductsById(P.ProductID, 2);

SELECT *
	FROM Production.Product AS P
	OUTER APPLY dbo.GetCountProductsById(P.ProductID, 2);

/* Point 4
	Изменяю созданную inline table-valued функцию, 
		сделав ее multistatement table-valued (предварительно сохранив для проверки код создания inline table-valued функции).
*/
DROP FUNCTION GetCountProductsById
GO

CREATE FUNCTION dbo.GetRowsByIdAndCount(@ProductID [int], @RowCount [int])
	RETURNS @ProductInventary TABLE
	(
		ProductID    int,
		LocationID   smallint,
		Shelf        nvarchar,
		Bin          tinyint,
		Quantity     int,
		rowguid      uniqueidentifier,
		ModifiedDate datetime
	)
	AS
	BEGIN
		INSERT INTO @ProductInventary
			SELECT ProductID, LocationID, Shelf, Bin, MaxQuantity, rowguid, ModifiedDate
			FROM (
				SELECT 
					ProductID,
					LocationID,
					Shelf,
					Bin,
					MAX(Quantity) OVER (PARTITION BY ProductID) AS MaxQuantity,
					rowguid,
					ModifiedDate,
					ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS RowNumber
					FROM Production.ProductInventory
					WHERE ProductID = @ProductID AND Shelf = 'A'
				) AS Result
			WHERE RowNumber <= @RowCount
		RETURN;
	END;
GO