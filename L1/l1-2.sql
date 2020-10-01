/* 1 */
SELECT Name, GroupName
FROM HumanResources.Department 
where GroupName='Executive General and Administration'

/* 2 */
SELECT 
	MAX(VacationHours) as MaxVacationHours
FROM HumanResources.Employee

/* 3 */
SELECT BusinessEntityId, JobTitle, Gender, BirthDate, HireDate
FROM HumanResources.Employee 
WHERE JobTitle LIKE '%Engineer%'
