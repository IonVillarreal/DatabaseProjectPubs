-- =============================================
CREATE TABLE [staging].[sales]
(
    [stor_id] CHAR(4) NOT NULL,
    [ord_num] VARCHAR(20) NOT NULL,
    [title_id] VARCHAR(6) NOT NULL,
    [ord_date] DATETIME NOT NULL,
    [qty] SMALLINT NOT NULL,
    [payterms] VARCHAR(12) NULL,
    
    -- Campos calculados durante staging
    [unit_price] MONEY NULL,
    [discount_percent] DECIMAL(5,2) DEFAULT 0,
    
    -- Metadatos de ETL
    [ETL_BatchID] INT NULL,
    [ETL_InsertedDate] DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX [IX_StagingSales_StorID] 
    ON [staging].[sales] ([stor_id]);

CREATE NONCLUSTERED INDEX [IX_StagingSales_TitleID] 
    ON [staging].[sales] ([title_id]);

CREATE NONCLUSTERED INDEX [IX_StagingSales_OrdNum] 
    ON [staging].[sales] ([ord_num]);

CREATE NONCLUSTERED INDEX [IX_StagingSales_OrdDate] 
    ON [staging].[sales] ([ord_date]);
GO