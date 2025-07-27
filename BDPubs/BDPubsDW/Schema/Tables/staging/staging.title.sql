CREATE TABLE [staging].[title]
(
    [title_id] VARCHAR(6) NOT NULL,
    [title] VARCHAR(80) NOT NULL,
    [type] CHAR(12) NULL,
    [pub_id] CHAR(3) NULL,
    [price] MONEY NULL,
    [advance] MONEY NULL,
    [royalty] INT NULL,
    [ytd_sales] INT NULL,
    [notes] VARCHAR(200) NULL,
    [pubdate] DATETIME NULL,
    
    -- Información desnormalizada del publisher
    [pub_name] VARCHAR(40) NULL,
    [pub_city] VARCHAR(20) NULL,
    [pub_state] CHAR(2) NULL,
    [pub_country] VARCHAR(30) NULL,
    
    -- Metadatos de ETL
    [ETL_BatchID] INT NULL,
    [ETL_InsertedDate] DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX [IX_StagingTitle_TitleID] 
    ON [staging].[title] ([title_id]);

CREATE NONCLUSTERED INDEX [IX_StagingTitle_PubID] 
    ON [staging].[title] ([pub_id]);
GO

