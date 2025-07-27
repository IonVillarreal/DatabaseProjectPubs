CREATE TABLE [staging].[store]
(
    [stor_id] CHAR(4) NOT NULL,
    [stor_name] VARCHAR(40) NULL,
    [stor_address] VARCHAR(40) NULL,
    [city] VARCHAR(20) NULL,
    [state] CHAR(2) NULL,
    [zip] CHAR(5) NULL,
    
    -- Metadatos de ETL
    [ETL_BatchID] INT NULL,
    [ETL_InsertedDate] DATETIME2 DEFAULT GETDATE()
);

-- Índice para lookup durante procesamiento
CREATE NONCLUSTERED INDEX [IX_StagingStore_StorID] 
    ON [staging].[store] ([stor_id]);
GO