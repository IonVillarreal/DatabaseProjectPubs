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