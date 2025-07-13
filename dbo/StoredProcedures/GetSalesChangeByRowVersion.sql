-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetSalesChangeByRowVersion]
	-- Add the parameters for the stored procedure here
(@startRow Bigint
,@endRow Bigint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT [stor_id]
      ,[ord_num]
      ,[ord_date]
      ,[qty]
      ,[payterms]
      ,[title_id]
	  ,OrderDateKey=DATEDIFF(s, '19700101', CONVERT(datetime,[ord_date]))
  FROM [pubs].[dbo].[sales] as s
  where s.[RowVersion]>CONVERT(rowversion, @startRow) and s.[RowVersion]<=CONVERT(rowversion, @endRow)
END

GO

