

CREATE PROCEDURE [dbo].[sp_GetRecordByCorrelationIdSource]
		@CorrelationId VARCHAR(50),
		@Source VARCHAR(50)
			
AS
BEGIN
	SET NOCOUNT ON;
	SELECT SubAccountId, UMID, Attempt, RouteIdUsed, TRY_PARSE(OperatorId as int) AS OperatorId
	FROM [dbo].[TrafficRecord] WITH(NOLOCK)
	WHERE CorrelationId = @CorrelationId and Source = @Source
END