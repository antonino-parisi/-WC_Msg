
-- =============================================
-- Author:		Anton Shchekalov
-- Last update date: 2016-06-22
-- Description:	Used in DRInListener
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetRecordByCorrelationIdDestination]
		@CorrelationId VARCHAR(50),
		@Destination VARCHAR(50),
		@RouteId varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Anton: I removed this wait because I don't understand why it must be here //2016-06-17
	--WAITFOR DELAY '00:00:00.100'
	
	SELECT SubAccountId, UMID, Attempt, RouteIdUsed, TRY_PARSE(OperatorId as int) AS OperatorId, Price, 'EUR' As Currency, ProtocolSource
	FROM [dbo].[TrafficRecord] WITH(NOLOCK)
	WHERE CorrelationId = @CorrelationId and Destination = @Destination
END