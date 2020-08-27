-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,21-03-2013,>
-- Description:	<Select cost session data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SelectCostSessionData]
		@SessionId NVARCHAR(250)				
AS
BEGIN

	SET NOCOUNT ON;

	INSERT dbo.tmp_CostSessionData 
	SELECT CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,
		CD.CURRENTPRICE,CD.CURRENTMARGIN,CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
		CD.UpdateMarginpercent,CD.InCostFile,OP.OperatorName,CD.ProposedRouteId,CD.UpdateCost,CD.RoutingMode,CD.RouteStatus
	FROM CostSessionData CD 
		INNER JOIN CostSession CS ON CD.SESSIONID=CS.SESSIONID
		LEFT OUTER JOIN Operator OP ON CD.Operator=OP.OperatorId 
	WHERE CD.SESSIONID=@SessionId AND CS.STATUS=1 AND CD.Impact='Yes'

	SELECT CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,
		CD.CURRENTPRICE,CD.CURRENTMARGIN,CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
		CD.UpdateMarginpercent,CD.InCostFile,OP.OperatorName,CD.ProposedRouteId,CD.UpdateCost,CD.RoutingMode,CD.RouteStatus
	FROM CostSessionData CD 
		INNER JOIN CostSession CS ON CD.SESSIONID=CS.SESSIONID
		LEFT OUTER JOIN Operator OP ON CD.Operator=OP.OperatorId 
	WHERE CD.SESSIONID=@SessionId AND CS.STATUS=1 AND CD.Impact='Yes'

END
