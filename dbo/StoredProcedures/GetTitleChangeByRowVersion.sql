-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetTitleChangeByRowVersion]
	-- Add the parameters for the stored procedure here
(@startRow Bigint
,@endRow Bigint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT t.[title_id]
      ,t.[title]
      ,t.[type]
      ,t.[price]
      ,t.[advance]
      ,t.[royalty]
      ,t.[ytd_sales]
      ,t.[notes]
      ,t.[pubdate]
      ,ta.[au_ord]
      ,ta.[royaltyper]
	  ,a.[au_id]
      ,a.[au_lname]
      ,a.[au_fname]
      ,a.[phone]
      ,a.[address]
      ,a.[city]
      ,a.[state]
      ,a.[zip]
      ,a.[contract]
	  ,r.[lorange]
      ,r.[hirange]
  FROM [pubs].[dbo].[titles] as t
  inner join [dbo].[titleauthor] as ta on  (t.title_id=ta.title_id)
  inner join [dbo].[authors] as a on (ta.au_id=a.au_id)
  inner join [dbo].[roysched] as r on (r.title_id=t.title_id)
  WHERE (t.RowVersion> convert(rowversion,@startRow) and t.RowVersion<= convert(rowversion,@endRow))
  or (ta.RowVersion> convert(rowversion,@startRow) and ta.RowVersion<= convert(rowversion,@endRow))
  or (a.RowVersion> convert(rowversion,@startRow) and a.RowVersion<= convert(rowversion,@endRow))
  or (r.RowVersion> convert(rowversion,@startRow) and r.RowVersion<= convert(rowversion,@endRow))
END

GO

