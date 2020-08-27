
-- =============================================
-- Author:		Raju Gupta
-- Create date: 19/09/2011
-- Description:	return the price details corresponding to a country
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPriceByCountry]  
@CountryName NVARCHAR(50)


	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT OP.Country,OP.OperatorName,PR.Price FROM Operator OP INNER JOIN PlanRouting PR ON OP.OperatorId=PR.Operator WHERE OP.Country=@CountryName
	
--SELECT TOP 1 AccountId FROM [Account] WHERE (SubAccountId = @SubAccountId );




END

