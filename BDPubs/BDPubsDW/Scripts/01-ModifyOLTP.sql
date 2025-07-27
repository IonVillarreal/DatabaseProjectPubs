-- =============================================
-- Modificaciones al OLTP para CDC
-- =============================================

-- Este script modifica la base de datos PUBS original
-- para agregar columnas RowVersion (TIMESTAMP) que 
-- permitirán detectar cambios automáticamente

USE pubs;
GO

-- =============================================
-- Agregar RowVersion a tablas principales
-- =============================================

-- Tabla stores (tiendas)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('stores') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE stores ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla stores';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla stores';
END;

-- Tabla sales (ventas)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('sales') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE sales ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla sales';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla sales';
END;

-- Tabla titles (títulos)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('titles') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE titles ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla titles';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla titles';
END;

-- Tabla publishers (editoriales)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('publishers') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE publishers ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla publishers';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla publishers';
END;

-- Tabla authors (autores)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('authors') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE authors ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla authors';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla authors';
END;

-- Tabla titleauthor (relación autores-títulos)
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('titleauthor') 
               AND name = 'RowVersion')
BEGIN
    ALTER TABLE titleauthor ADD RowVersion TIMESTAMP;
    PRINT 'RowVersion agregado a tabla titleauthor';
END
ELSE
BEGIN
    PRINT 'RowVersion ya existe en tabla titleauthor';
END;

-- =============================================
-- Crear función para obtener DBTS
-- =============================================
IF OBJECT_ID('GetDatabaseRowVersion', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE GetDatabaseRowVersion
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT @@DBTS AS CurrentRowVersion;
    END
    ');
    PRINT 'Procedimiento GetDatabaseRowVersion creado';
END
ELSE
BEGIN
    PRINT 'Procedimiento GetDatabaseRowVersion ya existe';
END;

-- =============================================
-- Verificar cambios realizados
-- =============================================
PRINT '';
PRINT '=== VERIFICACIÓN DE CAMBIOS ===';
PRINT 'RowVersion agregado a las siguientes tablas:';

SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE c.name = 'RowVersion'
  AND t.name IN ('stores', 'sales', 'titles', 'publishers', 'authors', 'titleauthor')
ORDER BY t.name;

-- =============================================
-- Probar función DBTS
-- =============================================
PRINT '';
PRINT '=== VALOR ACTUAL DE @@DBTS ===';
EXEC GetDatabaseRowVersion;

PRINT '';
PRINT 'Modificaciones al OLTP completadas exitosamente.';
PRINT 'El sistema ahora puede detectar cambios automáticamente.';

GO