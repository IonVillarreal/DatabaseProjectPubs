USE [PubsDataWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[DW_MergeFactSales]    Script Date: 31/07/2025 16:39:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[DW_MergeFactSales2]
AS
BEGIN

	UPDATE dc
	SET [stor_id_original]= sc.[stor_id]
       ,[title_id_original] = sc.[title_id]
       ,[ord_num]         = sc.[ord_num]
       ,[Quantity]        = sc.[qty]
       ,[PayTerms]        = sc.[payterms]
       ,[OrderDate]       = sc.[ord_date]
	FROM [dbo].[FactSales]         dc
	INNER JOIN [staging].[sales] sc ON (dc.[stor_id_original] = sc.[stor_id] 
    AND dc.[title_id_original] = sc.[title_id]
    AND dc.[ord_num] = sc.[ord_num])
END
