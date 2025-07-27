CREATE OR ALTER PROCEDURE [dbo].[DW_MergeDimTitle]
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimTitle AS target
    USING staging.title AS source
    ON (target.title_id_original = source.title_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        ISNULL(target.title, '') != ISNULL(source.title, '') OR
        ISNULL(target.type, '') != ISNULL(source.type, '') OR
        ISNULL(target.price, 0) != ISNULL(source.price, 0) OR
        ISNULL(target.publisher_name, '') != ISNULL(source.pub_name, '') OR
        ISNULL(target.publisher_city, '') != ISNULL(source.pub_city, '')
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
    DELETE FROM staging.title;
    
    PRINT 'DW_MergeDimTitle completado. Filas procesadas: ' + CAST(@@ROWCOUNT AS VARCHAR);
END;
GO