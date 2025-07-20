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