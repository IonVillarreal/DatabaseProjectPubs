-- =============================================
-- Staging Tables - Áreas Temporales para ETL
-- =============================================

USE PubsDataWarehouse;
GO

-- =============================================
-- StagingStore - Área temporal para tiendas
-- =============================================
CREATE TABLE StagingStore (
    -- NO tiene llave primaria para carga rápida
    stor_id CHAR(4) NOT NULL,
    stor_name VARCHAR(40) NULL,
    stor_address VARCHAR(40) NULL,
    city VARCHAR(20) NULL,
    state CHAR(2) NULL,
    zip CHAR(5) NULL,
    
    -- Metadatos de ETL
    ETL_BatchID INT NULL,
    ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
);

-- Índice para lookup durante procesamiento
CREATE NONCLUSTERED INDEX IX_StagingStore_StorID 
    ON StagingStore (stor_id);

-- =============================================
-- StagingSales - Área temporal para ventas
-- =============================================
CREATE TABLE StagingSales (
    -- NO tiene llave primaria para carga rápida
    stor_id CHAR(4) NOT NULL,
    ord_num VARCHAR(20) NOT NULL,
    title_id VARCHAR(6) NOT NULL,
    ord_date DATETIME NOT NULL,
    qty SMALLINT NOT NULL,
    payterms VARCHAR(12) NULL,
    
    -- Campos calculados durante staging
    unit_price MONEY NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    
    -- Metadatos de ETL
    ETL_BatchID INT NULL,
    ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX IX_StagingSales_StorID 
    ON StagingSales (stor_id);

CREATE NONCLUSTERED INDEX IX_StagingSales_TitleID 
    ON StagingSales (title_id);

CREATE NONCLUSTERED INDEX IX_StagingSales_OrdNum 
    ON StagingSales (ord_num);

CREATE NONCLUSTERED INDEX IX_StagingSales_OrdDate 
    ON StagingSales (ord_date);

-- =============================================
-- StagingTitle - Área temporal para títulos
-- =============================================
CREATE TABLE StagingTitle (
    -- NO tiene llave primaria para carga rápida
    title_id VARCHAR(6) NOT NULL,
    title VARCHAR(80) NOT NULL,
    type CHAR(12) NULL,
    pub_id CHAR(3) NULL,
    price MONEY NULL,
    advance MONEY NULL,
    royalty INT NULL,
    ytd_sales INT NULL,
    notes VARCHAR(200) NULL,
    pubdate DATETIME NULL,
    
    -- Información desnormalizada del publisher
    pub_name VARCHAR(40) NULL,
    pub_city VARCHAR(20) NULL,
    pub_state CHAR(2) NULL,
    pub_country VARCHAR(30) NULL,
    
    -- Metadatos de ETL
    ETL_BatchID INT NULL,
    ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX IX_StagingTitle_TitleID 
    ON StagingTitle (title_id);

CREATE NONCLUSTERED INDEX IX_StagingTitle_PubID 
    ON StagingTitle (pub_id);

-- =============================================
-- StagingAuthor - Área temporal para autores
-- =============================================
CREATE TABLE StagingAuthor (
    -- NO tiene llave primaria para carga rápida
    au_id VARCHAR(11) NOT NULL,
    title_id VARCHAR(6) NOT NULL,
    au_fname VARCHAR(20) NOT NULL,
    au_lname VARCHAR(40) NOT NULL,
    phone CHAR(12) NULL,
    address VARCHAR(40) NULL,
    city VARCHAR(20) NULL,
    state CHAR(2) NULL,
    zip CHAR(5) NULL,
    contract BIT NOT NULL,
    
    -- Información de la relación autor-título
    au_ord TINYINT NULL,
    royaltyper INT NULL,
    
    -- Información desnormalizada del título
    title VARCHAR(80) NULL,
    title_type CHAR(12) NULL,
    
    -- Metadatos de ETL
    ETL_BatchID INT NULL,
    ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX IX_StagingAuthor_AuthorID 
    ON StagingAuthor (au_id);

CREATE NONCLUSTERED INDEX IX_StagingAuthor_TitleID 
    ON StagingAuthor (title_id);

CREATE NONCLUSTERED INDEX IX_StagingAuthor_LastName 
    ON StagingAuthor (au_lname);

-- =============================================
-- Comentarios de documentación
-- =============================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Área temporal para carga de datos de tiendas - SIN llave primaria para máximo rendimiento',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StagingStore';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Área temporal para carga de datos de ventas - SIN llave primaria para máximo rendimiento',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StagingSales';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Área temporal para carga de datos de títulos - SIN llave primaria para máximo rendimiento',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StagingTitle';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Área temporal para carga de datos de autores - SIN llave primaria para máximo rendimiento',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StagingAuthor';

GO