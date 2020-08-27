
-- =============================================
-- Author:		Raju Gupta
-- Create date: 18/10/2011
-- Description:	return the invoice details 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCarrierByFeature]  
@Feature NVARCHAR(100)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SQL varchar(600)

	--SET @SQL = 
	--'SELECT OrderID, CustomerID, EmployeeID, OrderDate
	--FROM dbo.Orders
	--WHERE OrderID IN (' + @OrderList + ')'

	if @Feature='ALL' 
	begin	
	SELECT RouteId,Description,Active,IsRingtoneSupport,IsOptLogoSupport,IsPictureSupport,IsUnicodeSupport,IsFlashSupport,IsWapPushSupport,IsConcatenatedMessageSupport,Issue FROM CarrierConnections 
	end
		
	if @Feature<>'ALL'
	begin	
	SET @SQL ='SELECT RouteId,Description,Active,IsRingtoneSupport,IsOptLogoSupport,IsPictureSupport,IsUnicodeSupport,IsFlashSupport,IsWapPushSupport,IsConcatenatedMessageSupport,Issue FROM CarrierConnections where ' + @Feature
	print @SQL
	EXEC(@SQL)	
	end		
	
END



