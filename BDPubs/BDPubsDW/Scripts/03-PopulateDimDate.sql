-- =============================================
-- Poblar DimDate con Fechas
-- =============================================

USE PubsDataWarehouse;
GO

-- =============================================
-- Determinar rango de fechas desde PUBS
-- =============================================
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

-- Obtener fechas mínima y máxima de la base PUBS
SELECT 
    @StartDate = MIN(CAST(ord_date AS DATE)),
    @EndDate = MAX(CAST(ord_date AS DATE))
FROM pubs.dbo.sales;

-- Si no hay datos, usar rango por defecto
IF @StartDate IS NULL OR @EndDate IS NULL
BEGIN
    SET @StartDate = '1990-01-01';
    SET @EndDate = '2030-12-31';
END;

-- Extender el rango para cubrir años completos
SET @StartDate = CAST(YEAR(@StartDate) AS VARCHAR) + '-01-01';
SET @EndDate = CAST(YEAR(@EndDate) + 1 AS VARCHAR) + '-12-31';

PRINT 'Poblando DimDate desde ' + CAST(@StartDate AS VARCHAR) + ' hasta ' + CAST(@EndDate AS VARCHAR);

-- =============================================
-- Limpiar tabla DimDate (excepto registro especial)
-- =============================================
DELETE FROM DimDate WHERE DateKey > 0;

-- =============================================
-- Poblar DimDate con fechas
-- =============================================
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    DECLARE @DateKey INT = CAST(FORMAT(@CurrentDate, 'yyyyMMdd') AS INT);
    DECLARE @Year INT = YEAR(@CurrentDate);
    DECLARE @Month INT = MONTH(@CurrentDate);
    DECLARE @Day INT = DAY(@CurrentDate);
    DECLARE @DayOfWeek INT = DATEPART(WEEKDAY, @CurrentDate);
    DECLARE @DayOfYear INT = DATEPART(DAYOFYEAR, @CurrentDate);
    DECLARE @WeekOfYear INT = DATEPART(WEEK, @CurrentDate);
    DECLARE @Quarter INT = DATEPART(QUARTER, @CurrentDate);
    
    -- Nombres de mes
    DECLARE @MonthName VARCHAR(10) = DATENAME(MONTH, @CurrentDate);
    DECLARE @MonthNameShort CHAR(3) = LEFT(DATENAME(MONTH, @CurrentDate), 3);
    
    -- Nombres de día
    DECLARE @DayName VARCHAR(10) = DATENAME(WEEKDAY, @CurrentDate);
    DECLARE @DayNameShort CHAR(3) = LEFT(DATENAME(WEEKDAY, @CurrentDate), 3);
    
    -- Indicadores especiales
    DECLARE @IsWeekend BIT = CASE WHEN @DayOfWeek IN (1, 7) THEN 1 ELSE 0 END;
    
    -- Trimestre y semestre
    DECLARE @QuarterName VARCHAR(10) = 'Q' + CAST(@Quarter AS VARCHAR);
    DECLARE @SemesterNumber INT = CASE WHEN @Quarter <= 2 THEN 1 ELSE 2 END;
    DECLARE @SemesterName VARCHAR(15) = 'S' + CAST(@SemesterNumber AS VARCHAR);
    
    -- Formatos adicionales
    DECLARE @DateFormatted VARCHAR(10) = FORMAT(@CurrentDate, 'MM/dd/yyyy');
    DECLARE @MonthYear VARCHAR(7) = FORMAT(@CurrentDate, 'MM/yyyy');
    DECLARE @YearMonth VARCHAR(7) = FORMAT(@CurrentDate, 'yyyy/MM');
    
    -- Detectar feriados básicos (expandir según necesidad)
    DECLARE @IsHoliday BIT = 0;
    DECLARE @HolidayName VARCHAR(50) = NULL;
    
    -- Año Nuevo
    IF @Month = 1 AND @Day = 1
    BEGIN
        SET @IsHoliday = 1;
        SET @HolidayName = 'Año Nuevo';
    END
    -- Navidad
    ELSE IF @Month = 12 AND @Day = 25
    BEGIN
        SET @IsHoliday = 1;
        SET @HolidayName = 'Navidad';
    END
    -- Día de la Independencia (USA)
    ELSE IF @Month = 7 AND @Day = 4
    BEGIN
        SET @IsHoliday = 1;
        SET @HolidayName = 'Día de la Independencia';
    END;
    
    -- Insertar registro
    INSERT INTO DimDate (
        DateKey, FullDate, Year, Quarter, Month, Day,
        MonthName, MonthNameShort, DayName, DayNameShort,
        DayOfYear, WeekOfYear, DayOfWeek, IsWeekend,
        IsHoliday, HolidayName, QuarterName, SemesterNumber, SemesterName,
        DateFormatted, MonthYear, YearMonth
    )
    VALUES (
        @DateKey, @CurrentDate, @Year, @Quarter, @Month, @Day,
        @MonthName, @MonthNameShort, @DayName, @DayNameShort,
        @DayOfYear, @WeekOfYear, @DayOfWeek, @IsWeekend,
        @IsHoliday, @HolidayName, @QuarterName, @SemesterNumber, @SemesterName,
        @DateFormatted, @MonthYear, @YearMonth
    );
    
    -- Siguiente día
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- =============================================
-- Verificar población de DimDate
-- =============================================
DECLARE @RecordCount INT = (SELECT COUNT(*) FROM DimDate WHERE DateKey > 0);

PRINT '';
PRINT '=== VERIFICACIÓN DE DimDate ===';
PRINT 'Total de fechas insertadas: ' + CAST(@RecordCount AS VARCHAR);

-- Mostrar muestra de datos
SELECT TOP 10 
    DateKey,
    FullDate,
    DayName,
    MonthName,
    Year,
    Quarter,
    IsWeekend,
    IsHoliday,
    HolidayName
FROM DimDate 
WHERE DateKey > 0
ORDER BY DateKey;

-- Estadísticas por año
SELECT 
    Year,
    COUNT(*) AS TotalDays,
    SUM(CASE WHEN IsWeekend = 1 THEN 1 ELSE 0 END) AS WeekendDays,
    SUM(CASE WHEN IsHoliday = 1 THEN 1 ELSE 0 END) AS Holidays
FROM DimDate 
WHERE DateKey > 0
GROUP BY Year
ORDER BY Year;

-- Verificar fechas de ventas cubiertas
PRINT '';
PRINT '=== COBERTURA DE FECHAS DE VENTAS ===';

SELECT 
    'Fechas en Sales' AS Descripcion,
    COUNT(*) AS Cantidad,
    MIN(CAST(ord_date AS DATE)) AS FechaMinima,
    MAX(CAST(ord_date AS DATE)) AS FechaMaxima
FROM pubs.dbo.sales

UNION ALL

SELECT 
    'Fechas en DimDate' AS Descripcion,
    COUNT(*) AS Cantidad,
    MIN(FullDate) AS FechaMinima,
    MAX(FullDate) AS FechaMaxima
FROM DimDate 
WHERE DateKey > 0;

-- Verificar si todas las fechas de ventas tienen correspondencia en DimDate
IF EXISTS (
    SELECT 1 
    FROM pubs.dbo.sales s
    LEFT JOIN DimDate dd ON CAST(FORMAT(s.ord_date, 'yyyyMMdd') AS INT) = dd.DateKey
    WHERE dd.DateKey IS NULL
)
BEGIN
    PRINT 'WARNING: Algunas fechas de ventas no tienen correspondencia en DimDate';
    
    SELECT DISTINCT 
        CAST(s.ord_date AS DATE) AS FechaSinCobertura,
        CAST(FORMAT(s.ord_date, 'yyyyMMdd') AS INT) AS DateKeyEsperado
    FROM pubs.dbo.sales s
    LEFT JOIN DimDate dd ON CAST(FORMAT(s.ord_date, 'yyyyMMdd') AS INT) = dd.DateKey
    WHERE dd.DateKey IS NULL
    ORDER BY FechaSinCobertura;
END
ELSE
BEGIN
    PRINT 'SUCCESS: Todas las fechas de ventas tienen correspondencia en DimDate';
END;

PRINT '';
PRINT 'Población de DimDate completada exitosamente.';

GO