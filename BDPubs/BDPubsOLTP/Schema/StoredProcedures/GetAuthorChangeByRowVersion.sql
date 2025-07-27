-- =============================================
-- GetAuthorChangeByRowVersion.sql
-- Directorio: /BDPubs/BDPubsOLTP/Schema/StoredProcedures/
-- =============================================
CREATE PROCEDURE [dbo].[GetAuthorChangeByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.au_id,
        ta.title_id,        
        a.au_fname,         
        a.au_lname,         
        a.phone,
        a.address,
        a.city,
        a.state,
        a.zip,
        a.contract,
        ta.au_ord,
        ta.royaltyper,
        t.title,
        t.type as title_type
    FROM [pubs].[dbo].[authors] a
    INNER JOIN [pubs].[dbo].[titleauthor] ta ON a.au_id = ta.au_id  -- ✅ INNER JOIN
    INNER JOIN [pubs].[dbo].[titles] t ON ta.title_id = t.title_id   -- ✅ INNER JOIN
    WHERE a.[RowVersion] > CONVERT(rowversion, @startRow) 
      AND a.[RowVersion] <= CONVERT(rowversion, @endRow)
      OR (ta.[RowVersion] > CONVERT(rowversion, @startRow) 
          AND ta.[RowVersion] <= CONVERT(rowversion, @endRow));
END
GO