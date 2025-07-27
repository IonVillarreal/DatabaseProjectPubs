CREATE OR ALTER PROCEDURE [dbo].[GetLastPackageRowVersion]
(
    @tableName VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT LastRowVersion
    FROM [dbo].[PackageConfig]
    WHERE TableName = @tableName;
END;
GO