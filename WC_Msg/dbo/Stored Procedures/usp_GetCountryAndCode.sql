-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,08-03-2013,>
-- Description:	<Description,COUNTRY AND COUNTRYCODE>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCountryAndCode]
	-- Add the parameters for the stored procedure here
		--@AccountId NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT NP.CountryCode,OP.Country FROM [dbo].[Operator] OP 
  Inner JOIN  [dbo].[NumberingPlan] NP ON OP.Country=NP.Country
  ORDER BY NP.CountryCode ASC
  
  SELECT DISTINCT NP.CountryCode,OP.Country,OP.OperatorId,OP.OperatorName,opl.MCC,opl.MNC FROM [dbo].[Operator] OP 
  Inner JOIN  [dbo].[NumberingPlan] NP ON OP.Country=NP.Country
  Left outer join OperatorIdLookup opl on opl.OperatorId=op.OperatorId 
  ORDER BY NP.CountryCode ASC
  
  
END
