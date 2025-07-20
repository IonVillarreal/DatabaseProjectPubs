-- =============================================
-- FactSales - Tabla de Hechos de Ventas
-- =============================================

USE PubsDataWarehouse;
GO

-- Crear tabla de hechos Sales
CREATE TABLE FactSales (
    -- Surrogate Key compuesta
    SalesKey INT IDENTITY(1,1) NOT NULL,
    
    -- Foreign Keys a las dimensiones (Surrogate Keys)
    StoreKey INT NOT NULL,
    TitleKey INT NOT NULL,
    AuthorKey INT NULL,  -- Puede ser NULL si no hay autor específico
    OrderDateKey INT NOT NULL,
    
    -- Business Keys originales (para lookup y debugging)
    stor_id_original CHAR(4) NOT NULL,
    title_id_original VARCHAR(6) NOT NULL,
    ord_num_original VARCHAR(20) NOT NULL,
    
    -- Medidas del hecho (valores numéricos para análisis)
    Quantity SMALLINT NOT NULL,
    UnitPrice MONEY NULL,
    TotalAmount AS (Quantity * UnitPrice) PERSISTED,
    DiscountPercent DECIMAL(5,2) DEFAULT 0,
    DiscountAmount AS (Quantity * UnitPrice * DiscountPercent / 100) PERSISTED,
    NetAmount AS (Quantity * UnitPrice * (1 - DiscountPercent / 100)) PERSISTED,
    
    -- Información adicional de la venta
    PayTerms VARCHAR(12) NULL,
    
    -- Fechas originales (para comparación)
    OrderDate DATETIME NOT NULL,
    
    -- Metadatos de control
    RowInsertedDate DATETIME2 DEFAULT GETDATE(),
    RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
    ETL_BatchID INT NULL,
    
    -- Constraints
    CONSTRAINT PK_FactSales PRIMARY KEY (SalesKey),
    CONSTRAINT FK_FactSales_Store 
        FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey),
    CONSTRAINT FK_FactSales_Title 
        FOREIGN KEY (TitleKey) REFERENCES DimTitle(TitleKey),
    CONSTRAINT FK_FactSales_Author 
        FOREIGN KEY (AuthorKey) REFERENCES DimAuthor(AuthorKey),
    CONSTRAINT FK_FactSales_Date 
        FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
    
    -- Validaciones de negocio
    CONSTRAINT CK_FactSales_Quantity 
        CHECK (Quantity > 0),
    CONSTRAINT CK_FactSales_UnitPrice 
        CHECK (UnitPrice >= 0),
    CONSTRAINT CK_FactSales_DiscountPercent 
        CHECK (DiscountPercent >= 0 AND DiscountPercent <= 100)
);