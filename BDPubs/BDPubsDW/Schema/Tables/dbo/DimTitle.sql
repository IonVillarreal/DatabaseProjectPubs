-- =============================================
-- DimTitle - Dimensión de Libros (Desnormalizada)
-- =============================================

USE PubsDataWarehouse;
GO

-- Crear tabla de dimensión Title (incluye info de Publisher)
CREATE TABLE DimTitle (
    -- Surrogate Key (llave artificial)
    TitleKey INT IDENTITY(1,1) NOT NULL,
    
    -- Business Key (llave original del OLTP)
    title_id_original VARCHAR(6) NOT NULL,
    
    -- Atributos del libro
    title VARCHAR(80) NOT NULL,
    type CHAR(12) NULL,
    price MONEY NULL,
    advance MONEY NULL,
    royalty INT NULL,
    ytd_sales INT NULL,
    notes VARCHAR(200) NULL,
    pubdate DATETIME NULL,
    
    -- Información DESNORMALIZADA del Publisher
    pub_id_original CHAR(3) NULL,
    publisher_name VARCHAR(40) NULL,
    publisher_city VARCHAR(20) NULL,
    publisher_state CHAR(2) NULL,
    publisher_country VARCHAR(30) NULL,
    
    -- Metadatos de control
    RowInsertedDate DATETIME2 DEFAULT GETDATE(),
    RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
    IsCurrentRecord BIT DEFAULT 1,
    
    -- Constraints
    CONSTRAINT PK_DimTitle PRIMARY KEY (TitleKey),
);