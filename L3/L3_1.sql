/* Point a)
	Добавляю в таблицу dbo.StateProvince поле CountryRegionName типа nvarchar(50).
*/
ALTER TABLE dbo.StateProvince
    ADD CountryRegionName  NVARCHAR(50);
GO

/* Point b)
	Объявляю табличную переменную с такой же структурой как dbo.StateProvince и 
	заполняю ее данными из dbo.StateProvince. 
	Заполняю поле CountryRegionName данными из Person.CountryRegion поля Name.
*/
DECLARE @STATEPROVINCEVAR TABLE
	(
		StateProvinceId   [INT] NOT NULL,
		StateProvinceCode [NCHAR](3) NOT NULL,
		CountryRegionCode [NVARCHAR](3) NOT NULL,
		Name              [dbo].[NAME] NOT NULL,
		TerritoryId       [INT] NOT NULL,
		ModifiedDate      [DATETIME] NOT NULL,
		CountryRegionName [NVARCHAR](50)
	);
	INSERT INTO @StateProvinceVar
	SELECT SP.StateProvinceId,
		   SP.StateProvinceCode,
		   SP.CountryRegionCode,
		   SP.Name,
		   SP.TerritoryId,
		   SP.ModifiedDate,
		   CR.Name AS CountryRegionName
	FROM [dbo].[StateProvince] AS SP
	JOIN person.CountryRegion AS CR
		ON SP.CountryRegionCode = CR.CountryRegionCode;

/* Point c)
	Обновляю поле CountryRegionName в dbo.StateProvince данными из табличной переменной.
*/
UPDATE dbo.StateProvince
	SET CountryRegionName = V.CountryRegionName
	FROM @STATEPROVINCEVAR AS V
	WHERE StateProvince.StateProvinceId = V.StateProvinceId;
GO
Select * from dbo.StateProvince
/* Point d)
	Удаляю штаты из dbo.StateProvince, которые отсутствуют в таблице Person.Address.
*/
DELETE
	FROM dbo.StateProvince
	WHERE StateProvinceId NOT IN
		(
			SELECT StateProvinceId
			FROM person.address
		);
Select * from dbo.StateProvince

/* Point e)
	Удаляю поле CountryRegionName из таблицы и
	удаляю все созданные ограничения и значения по умолчанию.
*/
ALTER TABLE dbo.StateProvince
    DROP CONSTRAINT 
		ConstCountryRegionCodeNotNumber, 
		UniqName, 
		DefValueModifiedDate,
		COLUMN CountryRegionName;
GO

/* Point f)
	Удаляю таблицу dbo.StateProvince.
*/
DROP TABLE dbo.StateProvince;
GO