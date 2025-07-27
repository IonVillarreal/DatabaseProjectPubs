CREATE OR ALTER PROCEDURE [dbo].[DW_MergeFactSales]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insertar nuevas ventas (FactSales generalmente solo INSERT, no UPDATE)
    INSERT INTO FactSales (
        StoreKey,
        TitleKey,
        AuthorKey,
        OrderDateKey,
        stor_id_original,
        title_id_original,
        ord_num_original,
        Quantity,
        UnitPrice,
        DiscountPercent,
        PayTerms,
        OrderDate
    )
    SELECT 
        ds.StoreKey,
        dt.TitleKey,
        da.AuthorKey,
        ISNULL(dd.DateKey, 0),  -- Usar 0 si fecha no existe en DimDate
        ss.stor_id,
        ss.title_id,
        ss.ord_num,
        ss.qty,
        ss.unit_price,
        ISNULL(ss.discount_percent, 0),
        ss.payterms,
        ss.ord_date
    FROM staging.sales ss
    INNER JOIN DimStore ds ON ss.stor_id = ds.stor_id_original
    INNER JOIN DimTitle dt ON ss.title_id = dt.title_id_original
    LEFT JOIN DimAuthor da ON ss.title_id = da.title_id_original
    LEFT JOIN DimDate dd ON CONVERT(INT, FORMAT(ss.ord_date, 'yyyyMMdd')) = dd.DateKey
    WHERE NOT EXISTS (
        -- Evitar duplicados
        SELECT 1 FROM FactSales fs
        WHERE fs.stor_id_original = ss.stor_id
          AND fs.title_id_original = ss.title_id
          AND fs.ord_num_original = ss.ord_num
    );
    
    -- Limpiar tabla de staging
    DELETE FROM staging.sales;
    
    PRINT 'DW_MergeFactSales completado. Filas procesadas: ' + CAST(@@ROWCOUNT AS VARCHAR);
END;
GO