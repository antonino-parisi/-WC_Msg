-- =============================================
-- Author:		GUPTA,RAJU
-- Create date: 12-03-2013
-- Description:	Description,Get cost opid and cost details 
                -- for cost provisioining                                                 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCPopCostDetails]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT PR.AccountId,PR.SubAccountId,PR.RouteId,PR.Operator,PR.Cost,PR.Price, PR.Active,
		OP.Country,OP.OperatorName,PR.RoutingMode
    FROM planrouting PR
		left outer join Operator OP on PR.Operator=OP.OperatorId 
	WHERE PR.Active = 1

END





