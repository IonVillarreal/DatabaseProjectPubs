CREATE OR ALTER PROCEDURE [dbo].[DW_MergeDimStore]
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE DimStore AS target
    USING staging.store AS source
    ON (target.stor_id_original = source.stor_id)
    
    -- Actualizar registros existentes
    WHEN MATCHED AND (
        ISNULL(target.stor_name, '') != ISNULL(source.stor_name, '') OR
        ISNULL(target.stor_address, '') != ISNULL(source.stor_address, '') OR
        ISNULL(target.city, '') != ISNULL(source.city, '') OR
        ISNULL(target.state, '') != ISNULL(source.state, '') OR
        ISNULL(target.zip, '') != ISNULL(source.zip, '')
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
    DELETE FROM staging.store;
    
    PRINT 'DW_MergeDimStore completado. Filas procesadas: ' + CAST(@@ROWCOUNT AS VARCHAR);
END;
GO