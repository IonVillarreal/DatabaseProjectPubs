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
SELECT s.[stor_id]
		,s.[ord_num]
		,s.[ord_date]
		,s.[qty]
		,s.[payterms]
		,s.[title_id]
		,ta.[au_id]
		,CONVERT(INT, CONVERT(VARCHAR(8), s.[ord_date], 112)) AS OrderDateKey
FROM [dbo].[sales] AS s
INNER JOIN [dbo].[titleauthor] AS ta ON s.[title_id] = ta.[title_id]
where s.[RowVersion]>CONVERT(rowversion, @startRow) and s.[RowVersion]<=CONVERT(rowversion, @endRow)
END

GO

