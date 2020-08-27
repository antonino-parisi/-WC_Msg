-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,12-03-2013,>
-- Description:	<Description,Operatorid AND MCC and MNC>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetOpMccMnc]
	-- Add the parameters for the stored procedure here
		@Country NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--	SELECT OP.OperatorId,OP.OperatorName,OPL.MCC,OPL.MNC FROM Operator OP 
--INNER JOIN OperatorIdLookup OPL ON OP.OperatorId=OPL.OperatorId WHERE OP.Country=@Country ORDER BY OP.OperatorId ASC

SELECT distinct OP.OperatorId,OP.OperatorName,OPL.MCC, STUFF(( SELECT  ',' + MNC
                FROM    OperatorIdLookup OPL1  WHERE  OPL1.OperatorId in (OP.OperatorId)    
              FOR
                XML PATH('')
              ), 1, 1, '') AS 'MNCs'
FROM Operator OP
INNER JOIN OperatorIdLookup OPL ON OP.OperatorId=OPL.OperatorId WHERE OP.Country=@Country ORDER BY OP.OperatorId ASC  



END





