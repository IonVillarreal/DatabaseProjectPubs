-- =============================================
-- ETL Master Procedures - REEMPLAZA SSIS Packages
-- =============================================
-- Este archivo contiene los procedimientos que reemplazan
-- los packages .dtsx de SSIS para el ETL completo

USE PubsDataWarehouse;
GO

-- =============================================
-- sp_ETL_DimStore - Reemplaza DimStore.dtsx
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_DimStore
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartRowVersion BIGINT;
    DECLARE @EndRowVersion BIGINT;
    DECLARE @RowsProcessed INT = 0;
    
    BEGIN TRY
        -- 1. EXTRACT: Obtener último RowVersion procesado
        SELECT @StartRowVersion = LastRowVersion
        FROM PackageConfig 
        WHERE TableName = 'stores';
        
        -- 2. EXTRACT: Obtener RowVersion actual
        SELECT @EndRowVersion = @@DBTS;
        
        PRINT 'ETL DimStore - Procesando RowVersion ' + CAST(@StartRowVersion AS VARCHAR) + ' a ' + CAST(@EndRowVersion AS VARCHAR);
        
        -- 3. EXTRACT: Cargar cambios a staging
        INSERT INTO StagingStore (stor_id, stor_name, stor_address, city, state, zip)
        EXEC GetStoresByChange @StartRowVersion, @EndRowVersion;
        
        SET @RowsProcessed = @@ROWCOUNT;
        PRINT 'ETL DimStore - ' + CAST(@RowsProcessed AS VARCHAR) + ' registros extraídos';
        
        -- 4. TRANSFORM & LOAD: Fusionar staging con warehouse
        IF @RowsProcessed > 0
        BEGIN
            EXEC DW_MergeStore;
            PRINT 'ETL DimStore - Datos fusionados exitosamente';
            
            -- 5. UPDATE CONTROL: Actualizar configuración
            EXEC UpdateLastRowVersion 'stores', @EndRowVersion;
            PRINT 'ETL DimStore - RowVersion actualizado a ' + CAST(@EndRowVersion AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'ETL DimStore - No hay cambios que procesar';
        END;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'ERROR en ETL DimStore: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_DimTitle - Reemplaza DimTitle.dtsx
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_DimTitle
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartRowVersion BIGINT;
    DECLARE @EndRowVersion BIGINT;
    DECLARE @RowsProcessed INT = 0;
    
    BEGIN TRY
        -- 1. EXTRACT: Obtener último RowVersion procesado
        SELECT @StartRowVersion = LastRowVersion
        FROM PackageConfig 
        WHERE TableName = 'titles';
        
        -- 2. EXTRACT: Obtener RowVersion actual  
        SELECT @EndRowVersion = @@DBTS;
        
        PRINT 'ETL DimTitle - Procesando RowVersion ' + CAST(@StartRowVersion AS VARCHAR) + ' a ' + CAST(@EndRowVersion AS VARCHAR);
        
        -- 3. EXTRACT: Cargar cambios a staging
        INSERT INTO StagingTitle (title_id, title, type, pub_id, price, advance, royalty, ytd_sales, 
                                  notes, pubdate, pub_name, pub_city, pub_state, pub_country)
        EXEC GetTitlesByChange @StartRowVersion, @EndRowVersion;
        
        SET @RowsProcessed = @@ROWCOUNT;
        PRINT 'ETL DimTitle - ' + CAST(@RowsProcessed AS VARCHAR) + ' registros extraídos';
        
        -- 4. TRANSFORM & LOAD: Fusionar staging con warehouse
        IF @RowsProcessed > 0
        BEGIN
            EXEC DW_MergeTitle;
            PRINT 'ETL DimTitle - Datos fusionados exitosamente';
            
            -- 5. UPDATE CONTROL: Actualizar configuración
            EXEC UpdateLastRowVersion 'titles', @EndRowVersion;
            PRINT 'ETL DimTitle - RowVersion actualizado a ' + CAST(@EndRowVersion AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'ETL DimTitle - No hay cambios que procesar';
        END;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'ERROR en ETL DimTitle: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_DimAuthor - Reemplaza DimAuthor.dtsx
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_DimAuthor
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartRowVersion BIGINT;
    DECLARE @EndRowVersion BIGINT;
    DECLARE @RowsProcessed INT = 0;
    
    BEGIN TRY
        -- 1. EXTRACT: Obtener último RowVersion procesado
        SELECT @StartRowVersion = LastRowVersion
        FROM PackageConfig 
        WHERE TableName = 'authors';
        
        -- 2. EXTRACT: Obtener RowVersion actual
        SELECT @EndRowVersion = @@DBTS;
        
        PRINT 'ETL DimAuthor - Procesando RowVersion ' + CAST(@StartRowVersion AS VARCHAR) + ' a ' + CAST(@EndRowVersion AS VARCHAR);
        
        -- 3. EXTRACT: Cargar cambios a staging
        INSERT INTO StagingAuthor (au_id, title_id, au_fname, au_lname, phone, address, city, state, zip, 
                                   contract, au_ord, royaltyper, title, title_type)
        EXEC GetAuthorsByChange @StartRowVersion, @EndRowVersion;
        
        SET @RowsProcessed = @@ROWCOUNT;
        PRINT 'ETL DimAuthor - ' + CAST(@RowsProcessed AS VARCHAR) + ' registros extraídos';
        
        -- 4. TRANSFORM & LOAD: Fusionar staging con warehouse
        IF @RowsProcessed > 0
        BEGIN
            EXEC DW_MergeAuthor;
            PRINT 'ETL DimAuthor - Datos fusionados exitosamente';
            
            -- 5. UPDATE CONTROL: Actualizar configuración
            EXEC UpdateLastRowVersion 'authors', @EndRowVersion;
            PRINT 'ETL DimAuthor - RowVersion actualizado a ' + CAST(@EndRowVersion AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'ETL DimAuthor - No hay cambios que procesar';
        END;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'ERROR en ETL DimAuthor: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_FactSales - Reemplaza FactSales.dtsx
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_FactSales
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartRowVersion BIGINT;
    DECLARE @EndRowVersion BIGINT;
    DECLARE @RowsProcessed INT = 0;
    
    BEGIN TRY
        -- 1. EXTRACT: Obtener último RowVersion procesado
        SELECT @StartRowVersion = LastRowVersion
        FROM PackageConfig 
        WHERE TableName = 'sales';
        
        -- 2. EXTRACT: Obtener RowVersion actual
        SELECT @EndRowVersion = @@DBTS;
        
        PRINT 'ETL FactSales - Procesando RowVersion ' + CAST(@StartRowVersion AS VARCHAR) + ' a ' + CAST(@EndRowVersion AS VARCHAR);
        
        -- 3. EXTRACT: Cargar cambios a staging
        INSERT INTO StagingSales (stor_id, ord_num, title_id, ord_date, qty, payterms, unit_price, discount_percent)
        EXEC GetSalesByChange @StartRowVersion, @EndRowVersion;
        
        SET @RowsProcessed = @@ROWCOUNT;
        PRINT 'ETL FactSales - ' + CAST(@RowsProcessed AS VARCHAR) + ' registros extraídos';
        
        -- 4. TRANSFORM & LOAD: Fusionar staging con warehouse
        IF @RowsProcessed > 0
        BEGIN
            EXEC DW_MergeSales;
            PRINT 'ETL FactSales - Datos fusionados exitosamente';
            
            -- 5. UPDATE CONTROL: Actualizar configuración
            EXEC UpdateLastRowVersion 'sales', @EndRowVersion;
            PRINT 'ETL FactSales - RowVersion actualizado a ' + CAST(@EndRowVersion AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'ETL FactSales - No hay cambios que procesar';
        END;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'ERROR en ETL FactSales: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_ProcessDimensions - Procesa todas las dimensiones
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_ProcessDimensions
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '';
    PRINT '=== INICIANDO PROCESAMIENTO DE DIMENSIONES ===';
    PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
    
    BEGIN TRY
        -- Procesar dimensiones en orden de dependencia
        PRINT '';
        EXEC sp_ETL_DimStore;
        
        PRINT '';
        EXEC sp_ETL_DimTitle;
        
        PRINT '';
        EXEC sp_ETL_DimAuthor;
        
        PRINT '';
        PRINT '=== DIMENSIONES PROCESADAS EXITOSAMENTE ===';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '';
        PRINT '=== ERROR PROCESANDO DIMENSIONES ===';
        PRINT 'Error: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_IncrementalLoad - REEMPLAZA MasterETL.dtsx
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_IncrementalLoad
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '';
    PRINT '===========================================================';
    PRINT 'INICIANDO ETL INCREMENTAL - PUBS DATA WAREHOUSE';
    PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT '===========================================================';
    
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @ErrorCount INT = 0;
    
    BEGIN TRY
        -- 1. Procesar todas las dimensiones primero
        PRINT '';
        PRINT 'PASO 1: Procesando dimensiones...';
        EXEC sp_ETL_ProcessDimensions;
        
        -- 2. Procesar tabla de hechos
        PRINT '';
        PRINT 'PASO 2: Procesando tabla de hechos...';
        EXEC sp_ETL_FactSales;
        
        -- 3. Estadísticas finales
        DECLARE @EndTime DATETIME = GETDATE();
        DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
        
        PRINT '';
        PRINT '===========================================================';
        PRINT 'ETL INCREMENTAL COMPLETADO EXITOSAMENTE';
        PRINT 'Duración: ' + CAST(@Duration AS VARCHAR) + ' segundos';
        PRINT 'Fecha/Hora fin: ' + CONVERT(VARCHAR, @EndTime, 120);
        PRINT '===========================================================';
        
        -- 4. Mostrar estadísticas del warehouse
        EXEC sp_ETL_ShowStatistics;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT '';
        PRINT '===========================================================';
        PRINT 'ERROR EN ETL INCREMENTAL';
        PRINT 'Error: ' + @ErrorMessage;
        PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
        PRINT '===========================================================';
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_FullLoad - Carga completa inicial
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_FullLoad
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '';
    PRINT '===========================================================';
    PRINT 'INICIANDO ETL CARGA COMPLETA - PUBS DATA WAREHOUSE';
    PRINT 'ADVERTENCIA: Esto reiniciará todos los datos del warehouse';
    PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT '===========================================================';
    
    BEGIN TRY
        -- 1. Reiniciar configuración ETL
        PRINT '';
        PRINT 'PASO 1: Reiniciando configuración ETL...';
        EXEC ResetETLConfig;
        
        -- 2. Procesar carga incremental (que ahora será completa)
        PRINT '';
        PRINT 'PASO 2: Ejecutando carga completa...';
        EXEC sp_ETL_IncrementalLoad;
        
        PRINT '';
        PRINT '===========================================================';
        PRINT 'ETL CARGA COMPLETA TERMINADA EXITOSAMENTE';
        PRINT '===========================================================';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '';
        PRINT 'ERROR EN ETL CARGA COMPLETA: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- =============================================
-- sp_ETL_ShowStatistics - Mostrar estadísticas del warehouse
-- =============================================
CREATE OR ALTER PROCEDURE sp_ETL_ShowStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '';
    PRINT '=== ESTADÍSTICAS DEL DATA WAREHOUSE ===';
    
    -- Contar registros en cada tabla
    SELECT 
        'DimStore' AS Tabla,
        COUNT(*) AS Registros,
        MAX(RowUpdatedDate) AS UltimaActualizacion
    FROM DimStore
    
    UNION ALL
    
    SELECT 
        'DimTitle' AS Tabla,
        COUNT(*) AS Registros,
        MAX(RowUpdatedDate) AS UltimaActualizacion
    FROM DimTitle
    
    UNION ALL
    
    SELECT 
        'DimAuthor' AS Tabla,
        COUNT(*) AS Registros,
        MAX(RowUpdatedDate) AS UltimaActualizacion
    FROM DimAuthor
    
    UNION ALL
    
    SELECT 
        'FactSales' AS Tabla,
        COUNT(*) AS Registros,
        MAX(RowUpdatedDate) AS UltimaActualizacion
    FROM FactSales
    
    UNION ALL
    
    SELECT 
        'DimDate' AS Tabla,
        COUNT(*) AS Registros,
        CAST('N/A' AS DATETIME) AS UltimaActualizacion
    FROM DimDate;
    
    -- Estado del ETL
    PRINT '';
    PRINT '=== ESTADO DEL ETL ===';
    SELECT * FROM vw_ETLStatus;
    
    -- Resumen de ventas
    PRINT '';
    PRINT '=== RESUMEN DE VENTAS ===';
    SELECT 
        COUNT(*) AS TotalVentas,
        SUM(Quantity) AS TotalCantidad,
        SUM(TotalAmount) AS TotalMonto,
        AVG(TotalAmount) AS MontoPromedio,
        MIN(OrderDate) AS PrimeraVenta,
        MAX(OrderDate) AS UltimaVenta
    FROM FactSales;
END;
GO

-- =============================================
-- Comentarios de documentación
-- =============================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Procedimiento ETL que reemplaza DimStore.dtsx - Procesa cambios incrementales de tiendas',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_ETL_DimStore';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Procedimiento ETL maestro que reemplaza MasterETL.dtsx - Orquesta todo el proceso incremental',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_ETL_IncrementalLoad';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Procedimiento ETL para carga completa inicial - Reemplaza todos los datos del warehouse',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_ETL_FullLoad';

PRINT '';
PRINT '===========================================================';
PRINT 'ETL MASTER PROCEDURES CREADOS EXITOSAMENTE';
PRINT '===========================================================';
PRINT '';
PRINT 'Procedimientos disponibles:';
PRINT '- sp_ETL_DimStore      (Reemplaza DimStore.dtsx)';
PRINT '- sp_ETL_DimTitle      (Reemplaza DimTitle.dtsx)';
PRINT '- sp_ETL_DimAuthor     (Reemplaza DimAuthor.dtsx)';
PRINT '- sp_ETL_FactSales     (Reemplaza FactSales.dtsx)';
PRINT '- sp_ETL_ProcessDimensions (Procesa todas las dimensiones)';
PRINT '- sp_ETL_IncrementalLoad   (Reemplaza MasterETL.dtsx)';
PRINT '- sp_ETL_FullLoad          (Carga completa inicial)';
PRINT '- sp_ETL_ShowStatistics    (Estadísticas del warehouse)';
PRINT '';
PRINT 'Para ejecutar ETL completo: EXEC sp_ETL_IncrementalLoad';
PRINT 'Para carga inicial: EXEC sp_ETL_FullLoad';

GO