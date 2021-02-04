--Lab 1: "Create" Function with table name
IF OBJECT_ID (N'createQuery', N'IF') IS NOT NULL
	DROP FUNCTION createQuery;
GO
CREATE FUNCTION createQuery(@tableName VARCHAR(250))
RETURNS @query TABLE(
	datavalues VARCHAR(250) 
)
AS
BEGIN
	DECLARE @max_column INT = 5;
	SELECT @max_column = MAX(ORDINAL_POSITION) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName
	INSERT INTO @query (datavalues)
	SELECT CONCAT('CREATE TABLE ', @tableName, ' (')  AS queryPiece
	UNION ALL
	SELECT CONCAT(cols.COLUMN_NAME, ' ', DATA_TYPE,
	(CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CONCAT('(', CHARACTER_MAXIMUM_LENGTH, ')') END),
	(CASE WHEN tableConst.CONSTRAINT_NAME = keys.CONSTRAINT_NAME  THEN CONCAT(' ', tableConst.CONSTRAINT_TYPE) END),
	(CASE WHEN sysCol.is_identity = 1 THEN ' IDENTITY(1,1)' END),
	(CASE WHEN constKeys.CONSTRAINT_NAME = refConst.UNIQUE_CONSTRAINT_NAME THEN CONCAT(' REFERENCES ', constKeys.TABLE_NAME, '(', constKeys.COLUMN_NAME, ')') END),
	(CASE WHEN cols.ORDINAL_POSITION != @max_column THEN ',' END)) AS queryPiece
	FROM INFORMATION_SCHEMA.COLUMNS AS cols 
	LEFT JOIN information_schema.key_column_usage AS keys ON (keys.TABLE_NAME = cols.TABLE_NAME AND keys.COLUMN_NAME = cols.COLUMN_NAME)
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tableConst ON (tableConst.CONSTRAINT_NAME = keys.CONSTRAINT_NAME)
	LEFT JOIN information_schema.referential_constraints AS refConst ON (refConst.CONSTRAINT_NAME = keys.CONSTRAINT_NAME)
	LEFT JOIN information_schema.key_column_usage AS constKeys ON (constKeys.CONSTRAINT_NAME = refConst.UNIQUE_CONSTRAINT_NAME)
	LEFT JOIN sys.objects AS sysObj ON sysObj.name = cols.TABLE_NAME 
	LEFT join sys.columns AS sysCol ON sysCol.object_id = sysObj.object_id AND sysCol.name = cols.column_name
	WHERE cols.TABLE_NAME = @tableName
	UNION ALL
	SELECT ')'  AS queryPieces
	RETURN;
END
GO
SELECT * FROM createQuery('Taverns')
GO
SELECT * FROM createQuery('Services')
GO

/*
create function Func()
returns @T table(ColName int)
as
begin
  declare @Var int
  set @Var = 10
  insert into @T(ColName) values (@Var)
  return
end
*/

--Lab 2: Create Function for Pricing (x*y)
IF OBJECT_ID (N'dbo.servicePrice', N'FN') IS NOT NULL  
    DROP FUNCTION servicePrice;  
GO  
CREATE FUNCTION dbo.servicePrice(@ServiceID INT, @Quantity INT)  
RETURNS MONEY
AS   
BEGIN  
    DECLARE @ret INT;  
    SELECT @ret = s.Price *  @Quantity  
    FROM [ServicesSales] s
    WHERE s.ID = @ServiceID ;
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END; 
GO
SELECT dbo.servicePrice(1, 3) 
GO
--
