/* Point 1
	Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
		отображающую данные о количестве работников, 
		нанятых в каждый отдел (HumanResources.Department) 
		за определённый год (HumanResources.EmployeeDepartmentHistory.StartDate). 
	Список лет передайте в процедуру через входной параметр.

	Таким образом, вызов процедуры выглядит следующим образом:
	EXECUTE dbo.EmpCountByDep ‘[2003],[2004],[2005]’
*/
CREATE PROCEDURE dbo.NumberOfHireEmployeesByYear @Years varchar(MAX)
AS
BEGIN
    DECLARE @query AS nvarchar(MAX);
    set @query =
        '
			SELECT 
				Name,' + @Years + '
			FROM (
				Select Name, D.DepartmentID, YEAR(ED.StartDate) as StartYear
				FROM HumanResources.EmployeeDepartmentHistory AS ED
				JOIN HumanResources.Department AS D
					ON D.DepartmentID = ED.DepartmentID
			) AS DepartmentEmployees
			PIVOT (
				COUNT (DepartmentID)
				FOR StartYear
				IN (' + @Years + ')
			) AS CountOfEmployees
		'
    execute (@query);
END;
GO

EXECUTE dbo.NumberOfHireEmployeesByYear '[2003],[2004],[2005],[2006],[2007]';
