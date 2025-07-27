-- =============================================
-- DimDate - Dimensión de Fechas
-- =============================================

USE PubsDataWarehouse;
GO

-- Crear tabla de dimensión Date
CREATE TABLE DimDate (
    -- Primary Key en formato YYYYMMDD
    DateKey INT NOT NULL,
    
    -- Fecha completa
    FullDate DATE NOT NULL,
    
    -- Componentes de fecha
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Day INT NOT NULL,
    
    -- Nombres descriptivos
    MonthName VARCHAR(10) NOT NULL,
    MonthNameShort CHAR(3) NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    DayNameShort CHAR(3) NOT NULL,
    
    -- Información adicional
    DayOfYear INT NOT NULL,
    WeekOfYear INT NOT NULL,
    DayOfWeek INT NOT NULL,
    
    -- Indicadores especiales
    IsWeekend BIT NOT NULL,
    IsHoliday BIT DEFAULT 0,
    HolidayName VARCHAR(50) NULL,
    
    -- Trimestres y semestres
    QuarterName VARCHAR(10) NOT NULL,
    SemesterNumber INT NOT NULL,
    SemesterName VARCHAR(15) NOT NULL,
    
    -- Formatos adicionales para reportes
    DateFormatted VARCHAR(10) NOT NULL, -- MM/DD/YYYY
    MonthYear VARCHAR(7) NOT NULL,      -- MM/YYYY
    YearMonth VARCHAR(7) NOT NULL,      -- YYYY/MM
    
    -- Constraints
    CONSTRAINT PK_DimDate PRIMARY KEY (DateKey),
    CONSTRAINT UK_DimDate_FullDate UNIQUE (FullDate)
);

-- Índices para mejorar performance
CREATE NONCLUSTERED INDEX IX_DimDate_Year 
    ON DimDate (Year);

CREATE NONCLUSTERED INDEX IX_DimDate_Quarter 
    ON DimDate (Quarter);

CREATE NONCLUSTERED INDEX IX_DimDate_Month 
    ON DimDate (Month);

CREATE NONCLUSTERED INDEX IX_DimDate_MonthYear 
    ON DimDate (MonthYear);

CREATE NONCLUSTERED INDEX IX_DimDate_IsWeekend 
    ON DimDate (IsWeekend);

CREATE NONCLUSTERED INDEX IX_DimDate_DayName 
    ON DimDate (DayName);

-- Comentarios de documentación
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Dimensión de fechas con información desglosada para análisis temporal',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'DimDate';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Llave primaria en formato YYYYMMDD (ej: 20241218 = 18 dic 2024)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'DimDate',
    @level2type = N'COLUMN', @level2name = N'DateKey';

GO

-- Crear registro especial para fechas nulas o no válidas
INSERT INTO DimDate (
    DateKey, FullDate, Year, Quarter, Month, Day,
    MonthName, MonthNameShort, DayName, DayNameShort,
    DayOfYear, WeekOfYear, DayOfWeek, IsWeekend,
    QuarterName, SemesterNumber, SemesterName,
    DateFormatted, MonthYear, YearMonth
)
VALUES (
    0, '1900-01-01', 1900, 1, 1, 1,
    'Unknown', 'UNK', 'Unknown', 'UNK',
    1, 1, 1, 0,
    'Q1', 1, 'S1',
    '01/01/1900', '01/1900', '1900/01'
);

GO