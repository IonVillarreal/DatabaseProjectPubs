-- =============================================
-- DimAuthor - Dimensión de Autores (Desnormalizada)
-- =============================================

USE PubsDataWarehouse;
GO

-- Crear tabla de dimensión Author (incluye relación con títulos)
CREATE TABLE DimAuthor (
    -- Surrogate Key (llave artificial)
    AuthorKey INT IDENTITY(1,1) NOT NULL,
    
    -- Business Keys (llaves originales del OLTP)
    au_id_original VARCHAR(11) NOT NULL,
    title_id_original VARCHAR(6) NOT NULL,
    
    -- Atributos del autor
    au_fname VARCHAR(20) NOT NULL,
    au_lname VARCHAR(40) NOT NULL,
    author_full_name AS (au_fname + ' ' + au_lname) PERSISTED,
    phone CHAR(12) NULL,
    address VARCHAR(40) NULL,
    city VARCHAR(20) NULL,
    state CHAR(2) NULL,
    zip CHAR(5) NULL,
    contract BIT NOT NULL,
    
    -- Información de la relación autor-título (desde titleauthor)
    au_ord TINYINT NULL,
    royaltyper INT NULL,
    
    -- Información DESNORMALIZADA del título
    title VARCHAR(80) NULL,
    title_type CHAR(12) NULL,
    
    -- Metadatos de control
    RowInsertedDate DATETIME2 DEFAULT GETDATE(),
    RowUpdatedDate DATETIME2 DEFAULT GETDATE(),
    IsCurrentRecord BIT DEFAULT 1,
    
    -- Constraints
    CONSTRAINT PK_DimAuthor PRIMARY KEY (AuthorKey),
    CONSTRAINT UK_DimAuthor_AuthorTitle UNIQUE (au_id_original, title_id_original)
);