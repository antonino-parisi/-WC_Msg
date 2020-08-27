
-- =============================================
-- Author:		Raju Gupta
-- Create date: FEB-2014
-- Description:	return the price details corresponding to a country
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetGlobalPriceByCountry]  
@CountryName NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--declare @CountryName as nvarchar(50)
--set @CountryName='France'
	DECLARE @ACCOUNTID AS NVARCHAR(50)
	DECLARE @SUBACCOUNTID AS NVARCHAR(50)
	
	SELECT @ACCOUNTID=AccountId, @SUBACCOUNTID=SubAccountId from StandardAccount WHERE StandardRouteIdName='Standard_CP_HQ'    --WHERE StandardRouteIdName='Standard_1'
	--print @ACCOUNTID
	--print @SUBACCOUNTID
	
	SELECT MIN(PR.Price) as Price FROM Operator OP 
	INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
	 WHERE OP.Country=@CountryName and PR.AccountId=@ACCOUNTID AND PR.SubAccountId=@SUBACCOUNTID
	
   --SELECT TOP 1 AccountId FROM [Account] WHERE (SubAccountId = @SubAccountId );

END



