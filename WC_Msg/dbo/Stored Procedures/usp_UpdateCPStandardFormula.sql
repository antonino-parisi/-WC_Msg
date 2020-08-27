-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <28102013>
-- Description:	<Inserting the selcted Standard formula during CP>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateCPStandardFormula]
@FormulaName [nvarchar](250),
@SessionId [nvarchar](250)
AS
BEGIN
	            
	
	INSERT INTO SessionCPStandardFormula(FormulaName,SessionId) values(@FormulaName,@SessionId)
	
	
END
