-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,13-06-2013,>
-- Description:	<Description,get formula for given accountid and Subaccid>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetStandardFormula]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@SubAccountId NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
select pf.FormulaName,pf.CostFrom,pf.CostTo,pf.MarginPercent from StandardAccount 
acc inner join PricingFormula pf on acc.PricingFormulaName=pf.FormulaName 
and acc.AccountId=@AccountId AND acc.SubAccountId=@SubAccountId  --AND pf.FormulaName<>'new price = current price'
  
END




