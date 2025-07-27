-- =============================================
-- Inicialización de Configuración del ETL
-- =============================================

USE PubsDataWarehouse;
GO

-- =============================================
-- Crear tabla de configuración del ETL
-- =============================================
IF OBJECT_ID('PackageConfig', 'U') IS NULL
BEGIN
    CREATE TABLE PackageConfig (
        TableName VARCHAR(50) NOT NULL,
        LastRowVersion BIGINT NOT NULL DEFAULT 0,
        LastUpdated DATETIME2 DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        
        CONSTRAINT PK_PackageConfig PRIMARY KEY (TableName)
    );
    
    PRINT 'Tabla PackageConfig creada exitosamente';
END
ELSE
BEGIN
    PRINT 'Tabla PackageConfig ya existe';
END;

-- =============================================
-- Inicializar configuración para cada tabla
-- =============================================

-- Limpiar configuración existente (para reinicializar)
DELETE FROM PackageConfig;

-- Insertar configuración inicial (empezar desde 0)
INSERT INTO PackageConfig (TableName, LastRowVersion, LastUpdated)
VALUES 
    ('stores', 0, GETDATE()),
    ('sales', 0, GETDATE()),
    ('titles', 0, GETDATE()),
    ('publishers', 0, GETDATE()),
    ('authors', 0, GETDATE()),
    ('titleauthor', 0, GETDATE());

PRINT 'Configuración inicial insertada para todas las tablas';

-- =============================================
-- Función para obtener último RowVersion procesado
-- =============================================
IF OBJECT_ID('GetLastRowVersion', 'P') IS NOT NULL
    DROP PROCEDURE GetLastRowVersion;
GO

CREATE PROCEDURE GetLastRowVersion
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT LastRowVersion
    FROM PackageConfig
    WHERE TableName = @TableName
      AND IsActive = 1;
END;
GO

-- =============================================
-- Vista para monitoreo del ETL
-- =============================================
IF OBJECT_ID('vw_ETLStatus', 'V') IS NOT NULL
    DROP VIEW vw_ETLStatus;
GO

CREATE VIEW vw_ETLStatus
AS
SELECT 
    pc.TableName,
    pc.LastRowVersion,
    pc.LastUpdated,
    pc.IsActive,
    DATEDIFF(MINUTE, pc.LastUpdated, GETDATE()) AS MinutesSinceLastUpdate,
    CASE 
        WHEN DATEDIFF(MINUTE, pc.LastUpdated, GETDATE()) > 60 
        THEN 'WARNING: Más de 1 hora sin actualizar'
        WHEN DATEDIFF(MINUTE, pc.LastUpdated, GETDATE()) > 1440 
        THEN 'ERROR: Más de 1 día sin actualizar'
        ELSE 'OK'
    END AS Status
FROM PackageConfig pc
WHERE pc.IsActive = 1;
GO

-- =============================================
-- Verificar configuración inicial
-- =============================================
PRINT '';
PRINT '=== CONFIGURACIÓN INICIAL ===';
SELECT * FROM PackageConfig ORDER BY TableName;

PRINT '';
PRINT '=== ESTADO DEL ETL ===';
SELECT * FROM vw_ETLStatus;

-- =============================================
-- Procedimiento de limpieza para reiniciar ETL
-- =============================================
IF OBJECT_ID('ResetETLConfig', 'P') IS NOT NULL
    DROP PROCEDURE ResetETLConfig;
GO

CREATE PROCEDURE ResetETLConfig
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    TRY
        -- Limpiar todas las tablas de staging
        DELETE FROM StagingStore;
        DELETE FROM StagingSales;
        DELETE FROM StagingTitle;
        DELETE FROM StagingAuthor;
        
        -- Reiniciar configuración
        UPDATE PackageConfig 
        SET LastRowVersion = 0,
            LastUpdated = GETDATE();
        
        -- Opcional: Limpiar warehouse para carga completa
        -- DELETE FROM FactSales;
        -- DELETE FROM DimAuthor;
        -- DELETE FROM DimTitle WHERE TitleKey > 0;
        -- DELETE FROM DimStore WHERE StoreKey > 0;
        
        COMMIT TRANSACTION;
        
        PRINT 'Configuración del ETL reiniciada exitosamente';
        PRINT 'Todas las tablas staging han sido limpiadas';
        PRINT 'LastRowVersion reiniciado a 0 para todas las tablas';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- Comentarios de documentación
-- =============================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Tabla de configuración para control del ETL y tracking de RowVersion',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'PackageConfig';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene el último RowVersion procesado para una tabla específica',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetLastRowVersion';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Vista para monitorear el estado del ETL y detectar problemas',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vw_ETLStatus';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Reinicia completamente la configuración del ETL',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'ResetETLConfig';

PRINT '';
PRINT 'Inicialización de configuración completada exitosamente.';
PRINT 'El sistema está listo para ejecutar procesos ETL.';

GO