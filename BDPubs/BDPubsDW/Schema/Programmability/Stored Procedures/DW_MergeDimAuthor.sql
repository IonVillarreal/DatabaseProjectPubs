CREATE OR ALTER PROCEDURE [dbo].[DW_MergeDimAuthor]
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimAuthor AS target
    USING staging.author AS source
    ON (target.au_id_original = source.au_id AND target.title_id_original = source.title_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        ISNULL(target.au_fname, '') != ISNULL(source.au_fname, '') OR
        ISNULL(target.au_lname, '') != ISNULL(source.au_lname, '') OR
        ISNULL(target.phone, '') != ISNULL(source.phone, '') OR
        ISNULL(target.address, '') != ISNULL(source.address, '') OR
        ISNULL(target.city, '') != ISNULL(source.city, '') OR
        ISNULL(target.state, '') != ISNULL(source.state, '') OR
        ISNULL(target.zip, '') != ISNULL(source.zip, '') OR
        ISNULL(target.contract, 0) != ISNULL(source.contract, 0) OR
        ISNULL(target.au_ord, 0) != ISNULL(source.au_ord, 0) OR
        ISNULL(target.royaltyper, 0) != ISNULL(source.royaltyper, 0)
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
    DELETE FROM staging.author;
    
    PRINT 'DW_MergeDimAuthor completado. Filas procesadas: ' + CAST(@@ROWCOUNT AS VARCHAR);
END;
GO