CREATE OR ALTER PROCEDURE [dbo].[UpdateLastPackageRowVersion]
(
    @tableName VARCHAR(50),
    @lastRowVersion BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE [dbo].[PackageConfig]
    SET LastRowVersion = @lastRowVersion,
        LastUpdated = GETDATE()
    WHERE TableName = @tableName;
    
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO [dbo].[PackageConfig] (TableName, LastRowVersion, LastUpdated)
        VALUES (@tableName, @lastRowVersion, GETDATE());
    END;
    
    PRINT 'PackageConfig actualizado para ' + @tableName + ' con RowVersion: ' + CAST(@lastRowVersion AS VARCHAR);
END;
GO