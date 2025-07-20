-- =============================================
-- DimStore - Dimensión de Tiendas/Librerías
-- =============================================

USE PubsDataWarehouse;
GO

-- Crear tabla de dimensión Store
CREATE TABLE DimStore (
    -- Surrogate Key (llave artificial)
    StoreKey INT IDENTITY(1,1) NOT NULL,
    
    -- Business Key (llave original del OLTP)
    stor_id_original CHAR(4) NOT NULL,
    
    -- Atributos descriptivos
    stor_name VARCHAR(40) NULL,
    stor_address VARCHAR(40) NULL,
    city VARCHAR(20) NULL,
    state CHAR(2) NULL,
    zip CHAR(5) NULL,
    
    -- Metadatos de control
    RowInsertedDate DATETIME2 DEFAULT GETDATE(),
    RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
    IsCurrentRecord BIT DEFAULT 1,
    
    -- Constraints
    CONSTRAINT PK_DimStore PRIMARY KEY (StoreKey),
    CONSTRAINT UK_DimStore_StorID UNIQUE (stor_id_original)
);

-- Índices para mejorar performance
CREATE NONCLUSTERED INDEX IX_DimStore_StorName 
    ON DimStore (stor_name);

CREATE NONCLUSTERED INDEX IX_DimStore_City 
    ON DimStore (city);

CREATE NONCLUSTERED INDEX IX_DimStore_State 
    ON DimStore (state);

-- Comentarios de documentación
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Dimensión de tiendas/librerías para análisis de ventas',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'DimStore';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Llave artificial auto-generada para identificar únicamente cada tienda',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'DimStore',
    @level2type = N'COLUMN', @level2name = N'StoreKey';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Identificador original de la tienda en el sistema OLTP',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'DimStore',
    @level2type = N'COLUMN', @level2name = N'stor_id_original';

GO