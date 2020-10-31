/* Point a)
*/
CREATE VIEW dbo.ProductModelClusterView
    WITH ENCRYPTION, SCHEMABINDING
AS
SELECT C.CultureID,
       C.Name             AS C_Name,
       C.ModifiedDate     AS C_ModifiedDate,
       PM.CatalogDescription,
       PM.Instructions,
       PM.Name            AS PM_Name,
       PM.ProductModelID,
       PM.ModifiedDate    AS PM_ModifiedDate,
       PD.Description,
       PD.ProductDescriptionID,
       PD.rowguid,
       PD.ModifiedDate    AS PD_ModifiedDate,
       PMPDC.ModifiedDate AS PMPDC_ModifiedDate
	FROM Production.ProductModel AS PM
	JOIN Production.ProductModelProductDescriptionCulture AS PMPDC
		ON PM.ProductModelID = PMPDC.ProductModelID
	JOIN Production.Culture AS C
		ON C.CultureID = PMPDC.CultureID
	JOIN Production.ProductDescription AS PD
		ON PD.ProductDescriptionID = PMPDC.ProductDescriptionID;
GO

CREATE UNIQUE CLUSTERED INDEX PRODUCT_MODEL_INDX
    ON dbo.ProductModelClusterView (ProductModelID, CultureID);
GO

/* Point b)
*/
CREATE TRIGGER onInsertIntoProductModelVIew
		ON dbo.ProductModelClusterView
    INSTEAD OF 
		INSERT 
	AS
	BEGIN
		INSERT INTO Production.Culture(CultureID, Name)
			SELECT CultureID, C_Name
				FROM inserted;
		INSERT INTO Production.ProductModel(Name)
			SELECT PM_Name
				FROM inserted;
		INSERT INTO Production.ProductDescription([Description])
			SELECT [Description]
				FROM inserted;
		INSERT INTO Production.ProductModelProductDescriptionCulture(CultureID, ProductModelID, ProductDescriptionID)
		VALUES ((SELECT CultureID FROM inserted),
				IDENT_CURRENT('Production.ProductModel'),
				IDENT_CURRENT('Production.ProductDescription'));
	END;
GO

CREATE TRIGGER onUpdateProductModelVIew
		ON dbo.ProductModelClusterView
    INSTEAD OF
        UPDAtE
    AS
	BEGIN
		UPDATE Production.Culture
			SET Name = (SELECT C_Name FROM inserted), 
				ModifiedDate = GETDATE()
			WHERE Name = (SELECT C_Name FROM deleted);
		UPDATE Production.ProductModel
			SET Name = (SELECT PM_Name FROM inserted),
				ModifiedDate = GETDATE()
			WHERE Name = (SELECT PM_Name FROM deleted)
		UPDATE Production.ProductDescription
			SET [Description] = (SELECT [Description] FROM inserted),
				ModifiedDate  = GETDATE()
			WHERE [Description] = (SELECT [Description] FROM deleted)
	END;
GO

CREATE TRIGGER onDeleteFromProductModelVIew
		ON dbo.ProductModelClusterView
    INSTEAD OF
        DELETE
    AS
	BEGIN
		IF (SELECT CultureID FROM deleted) NOT IN 
			(SELECT CultureID FROM Production.ProductModelProductDescriptionCulture)
		BEGIN
			DELETE
				FROM Production.Culture
				WHERE CultureID = (SELECT CultureID FROM deleted);
		END;

		IF (SELECT ProductDescriptionID FROM deleted) NOT IN
			(SELECT ProductDescriptionID FROM Production.ProductModelProductDescriptionCulture)
		BEGIN
			DELETE
				FROM Production.ProductDescription
				WHERE ProductDescriptionID = (SELECT ProductDescriptionID FROM deleted);
		END;

		IF (SELECT ProductModelID FROM deleted) NOT IN 
			(SELECT ProductModelID FROM Production.ProductModelProductDescriptionCulture)
		BEGIN
			DELETE
				FROM Production.ProductModel
				WHERE ProductModelID = (SELECT ProductModelID FROM deleted);
		END;
	END;
GO

/* Point c)
*/
INSERT 
	INTO dbo.ProductModelClusterView(CultureID, C_Name, PM_Name, [Description])
	VALUES ('ru', 'Russian', 'Roga I Kopita', 'Have fun');

UPDATE dbo.ProductModelClusterView
	SET C_Name        = 'ModifiedRussian',
		PM_Name       = 'Super Roga I Kopita',
		[Description] = 'Have crazy fun'
	WHERE CultureID = 'ru' 
		AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
		AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');

DELETE
	FROM dbo.ProductModelClusterView
	WHERE CultureID = 'ru'
		AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
		AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');