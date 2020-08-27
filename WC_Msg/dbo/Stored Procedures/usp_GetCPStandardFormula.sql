-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,13-06-2013,>
-- Description:	<Description,get formula for given accountid and Subaccid>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCPStandardFormula]
	-- Add the parameters for the stored procedure here
		@SessionId [nvarchar](250)
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  Select * from PricingFormula where FormulaName in(Select FormulaName from SessionCPStandardFormula where SessionId=@SessionId)
 
END




