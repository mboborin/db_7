/* Point a)
	Создаем таблицу Production.ProductModelHst, 
	которая будет хранить информацию об изменениях в таблице Production.ProductModel.
	Поля, которые присутствуют в таблице: 
	ID — первичный ключ IDENTITY(1,1);
	Action — совершенное действие (insert, update или delete);
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию.
*/
CREATE TABLE Production.ProductModelHst
(
    ID [INT] IDENTITY (1,1) NOT NULL,
    [Action] VARCHAR(10) NOT NULL 
		CHECK ([Action] IN ('insert', 'update', 'delete')),
    ModifiedDate DATETIME NOT NULL,
    SourceID [INT],
    UserName VARCHAR(256)  NOT NULL
);

select * from Production.ProductModelHst
GO

/* Point b)
	Создаем один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.ProductModel. 
	Триггер заполняет таблицу Production.ProductModelHst 
	с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.
*/
CREATE 
	TRIGGER onProductModelChanged
    ON Production.ProductModel
    AFTER
        INSERT, UPDATE, DELETE AS
	BEGIN
		DECLARE @actionType varchar(20);
		DECLARE @sourceID int;
		IF EXISTS(SELECT * FROM inserted)
			BEGIN
				SELECT @sourceID = ProductModelID
				FROM inserted;
				IF EXISTS(SELECT * FROM deleted)
					SELECT @actionType = 'update';
				ELSE
					SELECT @actionType = 'insert';
			END;
		ELSE
			BEGIN
				IF EXISTS(SELECT * FROM deleted)
					SELECT @actionType = 'delete';
				SELECT @sourceID = ProductModelID
				FROM deleted;
			END;
		INSERT INTO Production.ProductModelHst([Action], ModifiedDate, SourceID, UserName)
		VALUES (@actionType, GETDATE(), @sourceID, USER_NAME());
	END;
GO

/* Point c)
	Создаем представление VIEW, отображающее все поля таблицы Production.ProductModel.
*/
CREATE VIEW ProductModelView AS
	SELECT *
	FROM Production.ProductModel;
GO

/* Point d)
	Вставляю новую строку в Production.ProductModel через представление.
	Обновляю вставленную строку. 
	Удаляю вставленную строку.
	Все три операции отображены в Production.ProductModelHst.
*/
INSERT
		INTO Production.ProductModel(Name)
		VALUES ('Roma');
	UPDATE Production.ProductModel
		SET Name = 'Roman'
		WHERE Name = 'Roma';
	DELETE
		FROM Production.ProductModel
		WHERE Name = 'Roman';
	SELECT *
		FROM Production.ProductModelHst;

SELECT * FROM Production.ProductModel;