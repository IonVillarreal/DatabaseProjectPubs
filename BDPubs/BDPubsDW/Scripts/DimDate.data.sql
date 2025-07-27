IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[DimDate])
BEGIN
    PRINT 'Poblando DimDate...';
    
    DECLARE @StartDate DATE = '1990-01-01';
    DECLARE @EndDate DATE = '2030-12-31';
    DECLARE @CurrentDate DATE = @StartDate;

    -- Insertar registro especial para fechas nulas
    INSERT INTO [dbo].[DimDate] (
        [DateKey], [FullDate], [Year], [Quarter], [Month], [Day],
        [MonthName], [MonthNameShort], [DayName], [DayNameShort],
        [DayOfYear], [WeekOfYear], [DayOfWeek], [IsWeekend],
        [IsHoliday], [HolidayName], [QuarterName], [SemesterNumber], [SemesterName],
        [DateFormatted], [MonthYear], [YearMonth]
    )
    VALUES (
        0, '1900-01-01', 1900, 1, 1, 1,
        'Unknown', 'UNK', 'Unknown', 'UNK',
        1, 1, 1, 0, 0, NULL, 'Q1', 1, 'S1',
        '01/01/1900', '01/1900', '1900/01'
    );

    -- Poblar fechas día por día
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
        
        -- Nombres de mes y día
        DECLARE @MonthName VARCHAR(10) = DATENAME(MONTH, @CurrentDate);
        DECLARE @MonthNameShort CHAR(3) = LEFT(DATENAME(MONTH, @CurrentDate), 3);
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
        
        -- Detectar feriados básicos
        DECLARE @IsHoliday BIT = 0;
        DECLARE @HolidayName VARCHAR(50) = NULL;
        
        IF @Month = 1 AND @Day = 1
        BEGIN
            SET @IsHoliday = 1;
            SET @HolidayName = 'New Year';
        END
        ELSE IF @Month = 12 AND @Day = 25
        BEGIN
            SET @IsHoliday = 1;
            SET @HolidayName = 'Christmas';
        END
        ELSE IF @Month = 7 AND @Day = 4
        BEGIN
            SET @IsHoliday = 1;
            SET @HolidayName = 'Independence Day';
        END;
        
        -- Insertar registro
        INSERT INTO [dbo].[DimDate] (
            [DateKey], [FullDate], [Year], [Quarter], [Month], [Day],
            [MonthName], [MonthNameShort], [DayName], [DayNameShort],
            [DayOfYear], [WeekOfYear], [DayOfWeek], [IsWeekend],
            [IsHoliday], [HolidayName], [QuarterName], [SemesterNumber], [SemesterName],
            [DateFormatted], [MonthYear], [YearMonth]
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

    DECLARE @RecordCount INT = (SELECT COUNT(*) FROM [dbo].[DimDate] WHERE DateKey > 0);
    PRINT 'DimDate poblada con ' + CAST(@RecordCount AS VARCHAR) + ' fechas';
END
ELSE
BEGIN
    PRINT 'DimDate ya contiene datos, omitiendo población';
END;
GO