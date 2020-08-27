-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Return all Numbering plan to MessageSphere cache
-- =============================================
CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateOperators]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Prefix, OperatorId 
	FROM dbo.NumberingPlan
	WHERE OperatorId IS NOT NULL 
		/* protection from invalid records */
		AND TRY_CAST(Prefix as bigint) IS NOT NULL
		AND TRY_CAST(OperatorId as int) IS NOT NULL
END
