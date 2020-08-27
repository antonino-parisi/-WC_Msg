
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-17
-- Description:	Call from DRInListener for case when we don't have Destination value
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetRecordByRouteIdCorrelationId]
	@RouteId varchar(50),
	@CorrelationId VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT SubAccountId, UMID, Attempt, RouteIdUsed, TRY_PARSE(OperatorId as int) AS OperatorId, Price, 'EUR' As Currency, ProtocolSource
	FROM [dbo].[TrafficRecord] WITH(NOLOCK)
	WHERE CorrelationId = @CorrelationId and RouteIdUsed = @RouteId
END
