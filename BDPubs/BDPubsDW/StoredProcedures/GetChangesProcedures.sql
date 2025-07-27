-- =============================================
-- Procedimientos para Detectar Cambios (CDC)
-- =============================================

USE PubsDataWarehouse;
GO

-- =============================================
-- GetDatabaseRowVersion - Obtiene el último DBTS
-- =============================================
CREATE OR ALTER PROCEDURE GetDatabaseRowVersion
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT @@DBTS AS CurrentRowVersion;
END;
GO

-- =============================================
-- GetStoresByChange - Obtiene tiendas modificadas
-- =============================================
CREATE OR ALTER PROCEDURE GetStoresByChange
    @StartRowVersion BIGINT,
    @EndRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        stor_id,
        stor_name,
        stor_address,
        city,
        state,
        zip,
        RowVersion
    FROM pubs.dbo.stores
    WHERE RowVersion > @StartRowVersion 
      AND RowVersion <= @EndRowVersion;
END;
GO

-- =============================================
-- GetSalesByChange - Obtiene ventas modificadas
-- =============================================
CREATE OR ALTER PROCEDURE GetSalesByChange
    @StartRowVersion BIGINT,
    @EndRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.stor_id,
        s.ord_num,
        s.title_id,
        s.ord_date,
        s.qty,
        s.payterms,
        -- Información adicional del título para cálculos
        t.price,
        -- Información de descuentos si existe
        ISNULL(d.discount, 0) as discount_percent,
        s.RowVersion
    FROM pubs.dbo.sales s
    LEFT JOIN pubs.dbo.titles t ON s.title_id = t.title_id
    LEFT JOIN pubs.dbo.discounts d ON s.stor_id = d.stor_id 
        AND s.qty BETWEEN ISNULL(d.lowqty, 0) AND ISNULL(d.highqty, 999999)
    WHERE s.RowVersion > @StartRowVersion 
      AND s.RowVersion <= @EndRowVersion;
END;
GO

-- =============================================
-- GetTitlesByChange - Obtiene títulos modificados
-- =============================================
CREATE OR ALTER PROCEDURE GetTitlesByChange
    @StartRowVersion BIGINT,
    @EndRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.title_id,
        t.title,
        t.type,
        t.pub_id,
        t.price,
        t.advance,
        t.royalty,
        t.ytd_sales,
        t.notes,
        t.pubdate,
        -- Información DESNORMALIZADA del publisher
        p.pub_name,
        p.city as pub_city,
        p.state as pub_state,
        p.country as pub_country,
        -- Control de cambios
        CASE 
            WHEN t.RowVersion > p.RowVersion THEN t.RowVersion
            ELSE p.RowVersion
        END as MaxRowVersion
    FROM pubs.dbo.titles t
    LEFT JOIN pubs.dbo.publishers p ON t.pub_id = p.pub_id
    WHERE t.RowVersion > @StartRowVersion 
      AND t.RowVersion <= @EndRowVersion
      OR (p.RowVersion > @StartRowVersion 
          AND p.RowVersion <= @EndRowVersion);
END;
GO

-- =============================================
-- GetAuthorsByChange - Obtiene autores modificados
-- =============================================
CREATE OR ALTER PROCEDURE GetAuthorsByChange
    @StartRowVersion BIGINT,
    @EndRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.au_id,
        a.au_lname,
        a.au_fname,
        a.phone,
        a.address,
        a.city,
        a.state,
        a.zip,
        a.contract,
        -- Información de la relación autor-título
        ta.title_id,
        ta.au_ord,
        ta.royaltyper,
        -- Información DESNORMALIZADA del título
        t.title,
        t.type as title_type,
        -- Control de cambios - tomar el máximo RowVersion
        CASE 
            WHEN a.RowVersion > ISNULL(t.RowVersion, 0) THEN a.RowVersion
            ELSE t.RowVersion
        END as MaxRowVersion
    FROM pubs.dbo.authors a
    LEFT JOIN pubs.dbo.titleauthor ta ON a.au_id = ta.au_id
    LEFT JOIN pubs.dbo.titles t ON ta.title_id = t.title_id
    WHERE a.RowVersion > @StartRowVersion 
      AND a.RowVersion <= @EndRowVersion
      OR (t.RowVersion > @StartRowVersion 
          AND t.RowVersion <= @EndRowVersion);
END;
GO

-- =============================================
-- Comentarios de documentación
-- =============================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene el valor actual del Database Timestamp (@@DBTS)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetDatabaseRowVersion';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene tiendas que han sido modificadas en un rango de RowVersion',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetStoresByChange';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene ventas que han sido modificadas en un rango de RowVersion',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetSalesByChange';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene títulos que han sido modificados en un rango de RowVersion',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetTitlesByChange';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene autores que han sido modificados en un rango de RowVersion',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'GetAuthorsByChange';

GO