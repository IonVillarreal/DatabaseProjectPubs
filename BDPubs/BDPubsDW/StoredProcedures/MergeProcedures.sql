-- =============================================
-- Procedimientos para Fusionar Staging con Warehouse
-- =============================================

USE PubsDataWarehouse;
GO

-- =============================================
-- DW_MergeStore - Fusiona datos de tiendas
-- =============================================
CREATE OR ALTER PROCEDURE DW_MergeStore
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimStore AS target
    USING StagingStore AS source
    ON (target.stor_id_original = source.stor_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        target.stor_name != source.stor_name OR
        target.stor_address != source.stor_address OR
        target.city != source.city OR
        target.state != source.state OR
        target.zip != source.zip
    ) THEN
        UPDATE SET
            stor_name = source.stor_name,
            stor_address = source.stor_address,
            city = source.city,
            state = source.state,
            zip = source.zip,
            RowUpdatedDate = GETDATE()
    
    -- Insertar registros nuevos
    WHEN NOT MATCHED BY target THEN
        INSERT (
            stor_id_original,
            stor_name,
            stor_address,
            city,
            state,
            zip
        )
        VALUES (
            source.stor_id,
            source.stor_name,
            source.stor_address,
            source.city,
            source.state,
            source.zip
        );
    
    -- Limpiar tabla de staging
    DELETE FROM StagingStore;
END;
GO

-- =============================================
-- DW_MergeTitle - Fusiona datos de títulos
-- =============================================
CREATE OR ALTER PROCEDURE DW_MergeTitle
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimTitle AS target
    USING StagingTitle AS source
    ON (target.title_id_original = source.title_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        target.title != source.title OR
        target.type != source.type OR
        target.price != source.price OR
        target.publisher_name != source.pub_name OR
        target.publisher_city != source.pub_city
    ) THEN
        UPDATE SET
            title = source.title,
            type = source.type,
            price = source.price,
            advance = source.advance,
            royalty = source.royalty,
            ytd_sales = source.ytd_sales,
            notes = source.notes,
            pubdate = source.pubdate,
            pub_id_original = source.pub_id,
            publisher_name = source.pub_name,
            publisher_city = source.pub_city,
            publisher_state = source.pub_state,
            publisher_country = source.pub_country,
            RowUpdatedDate = GETDATE()
    
    -- Insertar registros nuevos
    WHEN NOT MATCHED BY target THEN
        INSERT (
            title_id_original,
            title,
            type,
            price,
            advance,
            royalty,
            ytd_sales,
            notes,
            pubdate,
            pub_id_original,
            publisher_name,
            publisher_city,
            publisher_state,
            publisher_country
        )
        VALUES (
            source.title_id,
            source.title,
            source.type,
            source.price,
            source.advance,
            source.royalty,
            source.ytd_sales,
            source.notes,
            source.pubdate,
            source.pub_id,
            source.pub_name,
            source.pub_city,
            source.pub_state,
            source.pub_country
        );
    
    -- Limpiar tabla de staging
    DELETE FROM StagingTitle;
END;
GO

-- =============================================
-- DW_MergeAuthor - Fusiona datos de autores
-- =============================================
CREATE OR ALTER PROCEDURE DW_MergeAuthor
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimAuthor AS target
    USING StagingAuthor AS source
    ON (target.au_id_original = source.au_id AND target.title_id_original = source.title_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        target.au_fname != source.au_fname OR
        target.au_lname != source.au_lname OR
        target.phone != source.phone OR
        target.address != source.address OR
        target.city != source.city OR
        target.state != source.state OR
        target.zip != source.zip OR
        target.contract != source.contract OR
        target.au_ord != source.au_ord OR
        target.royaltyper != source.royaltyper
    ) THEN
        UPDATE SET
            au_fname = source.au_fname,
            au_lname = source.au_lname,
            phone = source.phone,
            address = source.address,
            city = source.city,
            state = source.state,
            zip = source.zip,
            contract = source.contract,
            au_ord = source.au_ord,
            royaltyper = source.royaltyper,
            title = source.title,
            title_type = source.title_type,
            RowUpdatedDate = GETDATE()
    
    -- Insertar registros nuevos
    WHEN NOT MATCHED BY target THEN
        INSERT (
            au_id_original,
            title_id_original,
            au_fname,
            au_lname,
            phone,
            address,
            city,
            state,
            zip,
            contract,
            au_ord,
            royaltyper,
            title,
            title_type
        )
        VALUES (
            source.au_id,
            source.title_id,
            source.au_fname,
            source.au_lname,
            source.phone,
            source.address,
            source.city,
            source.state,
            source.zip,
            source.contract,
            source.au_ord,
            source.royaltyper,
            source.title,
            source.title_type
        );
    
    -- Limpiar tabla de staging
    DELETE FROM StagingAuthor;
END;
GO

-- =============================================
-- DW_MergeSales - Fusiona datos de ventas
-- =============================================
CREATE OR ALTER PROCEDURE DW_MergeSales
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
        dd.DateKey,
        ss.stor_id,
        ss.title_id,
        ss.ord_num,
        ss.qty,
        ss.unit_price,
        ISNULL(ss.discount_percent, 0),
        ss.payterms,
        ss.ord_date
    FROM StagingS as ss
    INNER JOIN DimStore ds ON ss.stor_id = ds.stor_id_original
    INNER JOIN DimTitle dt ON ss.title_id = dt.title_id_original
    LEFT JOIN DimAuthor da ON ss.title_id = da.title_id_original
    INNER JOIN DimDate dd ON CONVERT(INT, FORMAT(ss.ord_date, 'yyyyMMdd')) = dd.DateKey
    WHERE NOT EXISTS (
        -- Evitar duplicados
        SELECT 1 FROM FactSales fs
        WHERE fs.stor_id_original = ss.stor_id
          AND fs.title_id_original = ss.title_id
          AND fs.ord_num_original = ss.ord_num
    );
    
    -- Limpiar tabla de staging
    DELETE FROM StagingSales;
END;
GO

-- =============================================
-- UpdateLastRowVersion - Actualiza control de ETL
-- =============================================
CREATE OR ALTER PROCEDURE UpdateLastRowVersion
    @TableName VARCHAR(50),
    @NewRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE PackageConfig 
    SET LastRowVersion = @NewRowVersion,
        LastUpdated = GETDATE()
    WHERE TableName = @TableName;
    
    -- Si no existe, insertar
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO PackageConfig (TableName, LastRowVersion, LastUpdated)
        VALUES (@TableName, @NewRowVersion, GETDATE());
    END;
END;
GO

-- =============================================
-- Comentarios de documentación
-- =============================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Fusiona datos de StagingStore con DimStore usando MERGE',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'DW_MergeStore';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Fusiona datos de StagingTitle con DimTitle usando MERGE',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'DW_MergeTitle';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Fusiona datos de StagingSales con FactSales',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'DW_MergeSales';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Actualiza la tabla de control con el último RowVersion procesado',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'UpdateLastRowVersion';

GO