-- =============================================
-- Script Maestro de Despliegue Completo
-- Data Warehouse PUBS
-- =============================================

-- Este script ejecuta todos los componentes del Data Warehouse
-- en el orden correcto para garantizar dependencias

PRINT '=======================================================';
PRINT 'INICIANDO DESPLIEGUE COMPLETO DEL DATA WAREHOUSE PUBS';
PRINT '=======================================================';
PRINT '';

-- =============================================
-- PASO 1: Crear base de datos del Data Warehouse
-- =============================================
PRINT 'PASO 1: Creando base de datos PubsDataWarehouse...';

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'PubsDataWarehouse')
BEGIN
    CREATE DATABASE PubsDataWarehouse;
    PRINT 'Base de datos PubsDataWarehouse creada exitosamente';
END
ELSE
BEGIN
    PRINT 'Base de datos PubsDataWarehouse ya existe';
END;

USE PubsDataWarehouse;
GO

-- =============================================
-- PASO 2: Modificar OLTP (agregar RowVersion)
-- =============================================
PRINT '';
PRINT 'PASO 2: Modificando OLTP para CDC...';

-- Ejecutar modificaciones al OLTP
-- (Contenido del archivo 01-ModifyOLTP.sql)
USE pubs;

-- Agregar RowVersion a tablas principales
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('stores') AND name = 'RowVersion')
    ALTER TABLE stores ADD RowVersion TIMESTAMP;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('sales') AND name = 'RowVersion')
    ALTER TABLE sales ADD RowVersion TIMESTAMP;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('titles') AND name = 'RowVersion')
    ALTER TABLE titles ADD RowVersion TIMESTAMP;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('publishers') AND name = 'RowVersion')
    ALTER TABLE publishers ADD RowVersion TIMESTAMP;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('authors') AND name = 'RowVersion')
    ALTER TABLE authors ADD RowVersion TIMESTAMP;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('titleauthor') AND name = 'RowVersion')
    ALTER TABLE titleauthor ADD RowVersion TIMESTAMP;

PRINT 'RowVersion agregado a todas las tablas OLTP';

USE PubsDataWarehouse;

-- =============================================
-- PASO 3: Crear tablas de dimensión
-- =============================================
PRINT '';
PRINT 'PASO 3: Creando tablas de dimensión...';

-- DimStore
IF OBJECT_ID('DimStore', 'U') IS NULL
BEGIN
    CREATE TABLE DimStore (
        StoreKey INT IDENTITY(1,1) NOT NULL,
        stor_id_original CHAR(4) NOT NULL,
        stor_name VARCHAR(40) NULL,
        stor_address VARCHAR(40) NULL,
        city VARCHAR(20) NULL,
        state CHAR(2) NULL,
        zip CHAR(5) NULL,
        RowInsertedDate DATETIME2 DEFAULT GETDATE(),
        RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
        IsCurrentRecord BIT DEFAULT 1,
        CONSTRAINT PK_DimStore PRIMARY KEY (StoreKey),
        CONSTRAINT UK_DimStore_StorID UNIQUE (stor_id_original)
    );
    PRINT 'DimStore creada';
END;

-- DimTitle
IF OBJECT_ID('DimTitle', 'U') IS NULL
BEGIN
    CREATE TABLE DimTitle (
        TitleKey INT IDENTITY(1,1) NOT NULL,
        title_id_original VARCHAR(6) NOT NULL,
        title VARCHAR(80) NOT NULL,
        type CHAR(12) NULL,
        price MONEY NULL,
        advance MONEY NULL,
        royalty INT NULL,
        ytd_sales INT NULL,
        notes VARCHAR(200) NULL,
        pubdate DATETIME NULL,
        pub_id_original CHAR(3) NULL,
        publisher_name VARCHAR(40) NULL,
        publisher_city VARCHAR(20) NULL,
        publisher_state CHAR(2) NULL,
        publisher_country VARCHAR(30) NULL,
        RowInsertedDate DATETIME2 DEFAULT GETDATE(),
        RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
        IsCurrentRecord BIT DEFAULT 1,
        CONSTRAINT PK_DimTitle PRIMARY KEY (TitleKey),
        CONSTRAINT UK_DimTitle_TitleID UNIQUE (title_id_original)
    );
    PRINT 'DimTitle creada';
END;

-- DimAuthor
IF OBJECT_ID('DimAuthor', 'U') IS NULL
BEGIN
    CREATE TABLE DimAuthor (
        AuthorKey INT IDENTITY(1,1) NOT NULL,
        au_id_original VARCHAR(11) NOT NULL,
        title_id_original VARCHAR(6) NOT NULL,
        au_fname VARCHAR(20) NOT NULL,
        au_lname VARCHAR(40) NOT NULL,
        author_full_name AS (au_fname + ' ' + au_lname) PERSISTED,
        phone CHAR(12) NULL,
        address VARCHAR(40) NULL,
        city VARCHAR(20) NULL,
        state CHAR(2) NULL,
        zip CHAR(5) NULL,
        contract BIT NOT NULL,
        au_ord TINYINT NULL,
        royaltyper INT NULL,
        title VARCHAR(80) NULL,
        title_type CHAR(12) NULL,
        RowInsertedDate DATETIME2 DEFAULT GETDATE(),
        RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
        IsCurrentRecord BIT DEFAULT 1,
        CONSTRAINT PK_DimAuthor PRIMARY KEY (AuthorKey),
        CONSTRAINT UK_DimAuthor_AuthorTitle UNIQUE (au_id_original, title_id_original)
    );
    PRINT 'DimAuthor creada';
END;

-- DimDate
IF OBJECT_ID('DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE DimDate (
        DateKey INT NOT NULL,
        FullDate DATE NOT NULL,
        Year INT NOT NULL,
        Quarter INT NOT NULL,
        Month INT NOT NULL,
        Day INT NOT NULL,
        MonthName VARCHAR(10) NOT NULL,
        MonthNameShort CHAR(3) NOT NULL,
        DayName VARCHAR(10) NOT NULL,
        DayNameShort CHAR(3) NOT NULL,
        DayOfYear INT NOT NULL,
        WeekOfYear INT NOT NULL,
        DayOfWeek INT NOT NULL,
        IsWeekend BIT NOT NULL,
        IsHoliday BIT DEFAULT 0,
        HolidayName VARCHAR(50) NULL,
        QuarterName VARCHAR(10) NOT NULL,
        SemesterNumber INT NOT NULL,
        SemesterName VARCHAR(15) NOT NULL,
        DateFormatted VARCHAR(10) NOT NULL,
        MonthYear VARCHAR(7) NOT NULL,
        YearMonth VARCHAR(7) NOT NULL,
        CONSTRAINT PK_DimDate PRIMARY KEY (DateKey),
        CONSTRAINT UK_DimDate_FullDate UNIQUE (FullDate)
    );
    
    -- Registro especial para fechas nulas
    INSERT INTO DimDate VALUES (
        0, '1900-01-01', 1900, 1, 1, 1,
        'Unknown', 'UNK', 'Unknown', 'UNK',
        1, 1, 1, 0, 0, NULL, 'Q1', 1, 'S1',
        '01/01/1900', '01/1900', '1900/01'
    );
    
    PRINT 'DimDate creada';
END;

-- =============================================
-- PASO 4: Crear tabla de hechos
-- =============================================
PRINT '';
PRINT 'PASO 4: Creando tabla de hechos...';

IF OBJECT_ID('FactSales', 'U') IS NULL
BEGIN
    CREATE TABLE FactSales (
        SalesKey INT IDENTITY(1,1) NOT NULL,
        StoreKey INT NOT NULL,
        TitleKey INT NOT NULL,
        AuthorKey INT NULL,
        OrderDateKey INT NOT NULL,
        stor_id_original CHAR(4) NOT NULL,
        title_id_original VARCHAR(6) NOT NULL,
        ord_num_original VARCHAR(20) NOT NULL,
        Quantity SMALLINT NOT NULL,
        UnitPrice MONEY NULL,
        TotalAmount AS (Quantity * UnitPrice) PERSISTED,
        DiscountPercent DECIMAL(5,2) DEFAULT 0,
        DiscountAmount AS (Quantity * UnitPrice * DiscountPercent / 100) PERSISTED,
        NetAmount AS (Quantity * UnitPrice * (1 - DiscountPercent / 100)) PERSISTED,
        PayTerms VARCHAR(12) NULL,
        OrderDate DATETIME NOT NULL,
        RowInsertedDate DATETIME2 DEFAULT GETDATE(),
        RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
        ETL_BatchID INT NULL,
        CONSTRAINT PK_FactSales PRIMARY KEY (SalesKey),
        CONSTRAINT FK_FactSales_Store FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey),
        CONSTRAINT FK_FactSales_Title FOREIGN KEY (TitleKey) REFERENCES DimTitle(TitleKey),
        CONSTRAINT FK_FactSales_Author FOREIGN KEY (AuthorKey) REFERENCES DimAuthor(AuthorKey),
        CONSTRAINT FK_FactSales_Date FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
        CONSTRAINT CK_FactSales_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_FactSales_UnitPrice CHECK (UnitPrice >= 0),
        CONSTRAINT CK_FactSales_DiscountPercent CHECK (DiscountPercent >= 0 AND DiscountPercent <= 100)
    );
    PRINT 'FactSales creada';
END;

-- =============================================
-- PASO 5: Crear tablas de staging
-- =============================================
PRINT '';
PRINT 'PASO 5: Creando tablas de staging...';

-- StagingStore
IF OBJECT_ID('StagingStore', 'U') IS NULL
BEGIN
    CREATE TABLE StagingStore (
        stor_id CHAR(4) NOT NULL,
        stor_name VARCHAR(40) NULL,
        stor_address VARCHAR(40) NULL,
        city VARCHAR(20) NULL,
        state CHAR(2) NULL,
        zip CHAR(5) NULL,
        ETL_BatchID INT NULL,
        ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'StagingStore creada';
END;

-- StagingSales
IF OBJECT_ID('StagingSales', 'U') IS NULL
BEGIN
    CREATE TABLE StagingSales (
        stor_id CHAR(4) NOT NULL,
        ord_num VARCHAR(20) NOT NULL,
        title_id VARCHAR(6) NOT NULL,
        ord_date DATETIME NOT NULL,
        qty SMALLINT NOT NULL,
        payterms VARCHAR(12) NULL,
        unit_price MONEY NULL,
        discount_percent DECIMAL(5,2) DEFAULT 0,
        ETL_BatchID INT NULL,
        ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'StagingSales creada';
END;

-- StagingTitle y StagingAuthor (versiones simplificadas)
IF OBJECT_ID('StagingTitle', 'U') IS NULL
BEGIN
    CREATE TABLE StagingTitle (
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
        pub_name VARCHAR(40) NULL,
        pub_city VARCHAR(20) NULL,
        pub_state CHAR(2) NULL,
        pub_country VARCHAR(30) NULL,
        ETL_BatchID INT NULL,
        ETL_InsertedDate DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'StagingTitle creada';
END;

-- =============================================
-- PASO 6: Crear configuración del ETL
-- =============================================
PRINT '';
PRINT 'PASO 6: Creando configuración del ETL...';

IF OBJECT_ID('PackageConfig', 'U') IS NULL
BEGIN
    CREATE TABLE PackageConfig (
        TableName VARCHAR(50) NOT NULL,
        LastRowVersion BIGINT NOT NULL DEFAULT 0,
        LastUpdated DATETIME2 DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        CONSTRAINT PK_PackageConfig PRIMARY KEY (TableName)
    );
    
    -- Inicializar configuración
    INSERT INTO PackageConfig (TableName, LastRowVersion, LastUpdated)
    VALUES 
        ('stores', 0, GETDATE()),
        ('sales', 0, GETDATE()),
        ('titles', 0, GETDATE()),
        ('publishers', 0, GETDATE()),
        ('authors', 0, GETDATE()),
        ('titleauthor', 0, GETDATE());
    
    PRINT 'PackageConfig creada e inicializada';
END;

-- =============================================
-- PASO 7: Crear procedimientos almacenados básicos
-- =============================================
PRINT '';
PRINT 'PASO 7: Creando procedimientos almacenados...';

-- GetDatabaseRowVersion
IF OBJECT_ID('GetDatabaseRowVersion', 'P') IS NULL
BEGIN
    EXEC('CREATE PROCEDURE GetDatabaseRowVersion AS SELECT @@DBTS AS CurrentRowVersion;');
    PRINT 'GetDatabaseRowVersion creado';
END;

-- UpdateLastRowVersion
IF OBJECT_ID('UpdateLastRowVersion', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE UpdateLastRowVersion
        @TableName VARCHAR(50),
        @NewRowVersion BIGINT
    AS
    BEGIN
        UPDATE PackageConfig 
        SET LastRowVersion = @NewRowVersion, LastUpdated = GETDATE()
        WHERE TableName = @TableName;
        
        IF @@ROWCOUNT = 0
            INSERT INTO PackageConfig (TableName, LastRowVersion, LastUpdated)
            VALUES (@TableName, @NewRowVersion, GETDATE());
    END
    ');
    PRINT 'UpdateLastRowVersion creado';
END;

-- =============================================
-- PASO 8: Poblar DimDate básico
-- =============================================
PRINT '';
PRINT 'PASO 8: Poblando DimDate...';

-- Poblar algunas fechas básicas (simplificado)
DECLARE @StartDate DATE = '1990-01-01';
DECLARE @EndDate DATE = '2030-12-31';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate AND DAY(@CurrentDate) = 1 -- Solo primer día de cada mes para acelerar
BEGIN
    DECLARE @DateKey INT = CAST(FORMAT(@CurrentDate, 'yyyyMMdd') AS INT);
    
    IF NOT EXISTS (SELECT 1 FROM DimDate WHERE DateKey = @DateKey)
    BEGIN
        INSERT INTO DimDate (
            DateKey, FullDate, Year, Quarter, Month, Day,
            MonthName, MonthNameShort, DayName, DayNameShort,
            DayOfYear, WeekOfYear, DayOfWeek, IsWeekend,
            QuarterName, SemesterNumber, SemesterName,
            DateFormatted, MonthYear, YearMonth
        )
        VALUES (
            @DateKey, @CurrentDate, YEAR(@CurrentDate), DATEPART(QUARTER, @CurrentDate), 
            MONTH(@CurrentDate), DAY(@CurrentDate),
            DATENAME(MONTH, @CurrentDate), LEFT(DATENAME(MONTH, @CurrentDate), 3),
            DATENAME(WEEKDAY, @CurrentDate), LEFT(DATENAME(WEEKDAY, @CurrentDate), 3),
            DATEPART(DAYOFYEAR, @CurrentDate), DATEPART(WEEK, @CurrentDate), 
            DATEPART(WEEKDAY, @CurrentDate), 
            CASE WHEN DATEPART(WEEKDAY, @CurrentDate) IN (1,7) THEN 1 ELSE 0 END,
            'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS VARCHAR),
            CASE WHEN DATEPART(QUARTER, @CurrentDate) <= 2 THEN 1 ELSE 2 END,
            'S' + CASE WHEN DATEPART(QUARTER, @CurrentDate) <= 2 THEN '1' ELSE '2' END,
            FORMAT(@CurrentDate, 'MM/dd/yyyy'),
            FORMAT(@CurrentDate, 'MM/yyyy'),
            FORMAT(@CurrentDate, 'yyyy/MM')
        );
    END;
    
    SET @CurrentDate = DATEADD(MONTH, 1, @CurrentDate);
END;

PRINT 'DimDate poblada básicamente';

-- =============================================
-- VERIFICACIÓN FINAL
-- =============================================
PRINT '';
PRINT '=== VERIFICACIÓN FINAL ===';

SELECT 
    'Tablas creadas' AS Categoria,
    COUNT(*) AS Cantidad
FROM sys.tables 
WHERE name IN ('DimStore', 'DimTitle', 'DimAuthor', 'DimDate', 'FactSales', 
               'StagingStore', 'StagingSales', 'StagingTitle', 'PackageConfig')

UNION ALL

SELECT 
    'Procedimientos creados' AS Categoria,
    COUNT(*) AS Cantidad
FROM sys.procedures
WHERE name IN ('GetDatabaseRowVersion', 'UpdateLastRowVersion')

UNION ALL

SELECT 
    'Registros en DimDate' AS Categoria,
    COUNT(*) AS Cantidad
FROM DimDate

UNION ALL

SELECT 
    'Configuraciones ETL' AS Categoria,
    COUNT(*) AS Cantidad
FROM PackageConfig;

PRINT '';
PRINT '=======================================================';
PRINT 'DESPLIEGUE COMPLETO DEL DATA WAREHOUSE TERMINADO';
PRINT '=======================================================';
PRINT '';
PRINT 'El Data Warehouse está listo para recibir datos del ETL.';
PRINT 'Próximo paso: Implementar paquetes SSIS para cargar datos.';

GO