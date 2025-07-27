IF OBJECT_ID('PackageConfig', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PackageConfig]
    (
        [PackageID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT PK_PackageConfig PRIMARY KEY,
        [TableName] [varchar](50) NOT NULL,
        [LastRowVersion] [bigint] NULL,
        [LastUpdated] [datetime2] DEFAULT GETDATE()
    );
    PRINT 'Tabla PackageConfig creada';
END;

-- Insertar configuración inicial para todas las tablas OLTP
IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'stores')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('stores', 0, GETDATE());
END;

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'sales')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('sales', 0, GETDATE());
END;

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'titles')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('titles', 0, GETDATE());
END;

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'publishers')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('publishers', 0, GETDATE());
END;

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'authors')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('authors', 0, GETDATE());
END;

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'titleauthor')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion], [LastUpdated]) VALUES ('titleauthor', 0, GETDATE());
END;

PRINT 'PackageConfig inicializada con todas las tablas OLTP';
GO