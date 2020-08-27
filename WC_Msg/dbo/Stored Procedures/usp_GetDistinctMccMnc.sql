-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,12-03-2013,>
-- Description:	<Description,Operatorid AND MCC and MNC>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDistinctMccMnc]
	-- Add the parameters for the stored procedure here
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
--	SELECT OP.OperatorId,OP.OperatorName,OPL.MCC,OPL.MNC FROM Operator OP 
--INNER JOIN OperatorIdLookup OPL ON OP.OperatorId=OPL.OperatorId WHERE OP.Country=@Country ORDER BY OP.OperatorId ASC
SELECT distinct MCC from OperatorIdLookup 
SELECT distinct MNC from OperatorIdLookup


END





