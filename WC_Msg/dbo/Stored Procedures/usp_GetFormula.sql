-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,13-06-2013,>
-- Description:	<Description,get formula for given accountid and Subaccid>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFormula]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@SubAccountId NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 if exists(select * from StandardAccount where AccountId=@AccountId and SubAccountId=@SubAccountId)
 begin
 select pf.FormulaName,pf.CostFrom,pf.CostTo,pf.MarginPercent,pf.Price from StandardAccount 
acc inner join PricingFormula pf on acc.PricingFormulaName=pf.FormulaName 
and acc.AccountId=@AccountId AND acc.SubAccountId=@SubAccountId 
 end
 
 else
 
 begin
 
select pf.FormulaName,pf.CostFrom,pf.CostTo,pf.MarginPercent,pf.Price from Account 
acc inner join PricingFormula pf on acc.PricingFormula=pf.FormulaName 
and acc.AccountId=@AccountId AND acc.SubAccountId=@SubAccountId  --AND pf.FormulaName<>'new price = current price'
end



  
END




