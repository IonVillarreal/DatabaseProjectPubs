-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetStoresChangeByRowVersion]
	-- Add the parameters for the stored procedure here
(@startRow Bigint
,@endRow Bigint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT s.[stor_id]
      ,s.[stor_name]
      ,s.[stor_address]
      ,s.[city]
      ,s.[state]
      ,s.[zip]
	  ,d.[discounttype]
      ,d.[lowqty]
      ,d.[highqty]
      ,d.[discount]
        FROM [dbo].[stores] as s
		LEFT join [dbo].[discounts] as d on (s.stor_id=d.stor_id)
		WHERE (s.[RowVersion]>CONVERT(rowversion, @startRow) and s.[RowVersion]<=CONVERT(rowversion, @endRow))
		or (d.RowVersion> convert(rowversion,@startRow) and d.RowVersion<= convert(rowversion,@endRow))
END

GO

