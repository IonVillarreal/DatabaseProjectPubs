CREATE TABLE [staging].[author]
(
    [au_id] VARCHAR(11) NOT NULL,
    [title_id] VARCHAR(6) NOT NULL,
    [au_fname] VARCHAR(20) NOT NULL,
    [au_lname] VARCHAR(40) NOT NULL,
    [phone] CHAR(12) NULL,
    [address] VARCHAR(40) NULL,
    [city] VARCHAR(20) NULL,
    [state] CHAR(2) NULL,
    [zip] CHAR(5) NULL,
    [contract] BIT NOT NULL,
    
    -- Información de la relación autor-título
    [au_ord] TINYINT NULL,
    [royaltyper] INT NULL,
    
    -- Información desnormalizada del título
    [title] VARCHAR(80) NULL,
    [title_type] CHAR(12) NULL,
    
    -- Metadatos de ETL
    [ETL_BatchID] INT NULL,
    [ETL_InsertedDate] DATETIME2 DEFAULT GETDATE()
);

-- Índices para lookup durante procesamiento
CREATE NONCLUSTERED INDEX [IX_StagingAuthor_AuthorID] 
    ON [staging].[author] ([au_id]);

CREATE NONCLUSTERED INDEX [IX_StagingAuthor_TitleID] 
    ON [staging].[author] ([title_id]);

CREATE NONCLUSTERED INDEX [IX_StagingAuthor_LastName] 
    ON [staging].[author] ([au_lname]);
GO