
-- =============================================
-- Author:		James Santos, Hirantha Neranjan
-- Create date:  2016-05-26
-- Description:	List of CSG Logs by filter of @StatusId, @OperatorId, @RouteId
-- =================================================
-- EXEC [gtn].[CSG_Log_GetByOperatorIdRouteId] @RouteId = '42tele_x1', @OperatorId = 525003, @StatusId = 20
-- =================================================
CREATE PROCEDURE [gtn].[CSG_Log_GetByOperatorIdRouteId]
	@StatusId int,
	@OperatorId int,
	@RouteId varchar(50),
	@Limit int = 50
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @Limit > 100 SET @Limit = 100

	SELECT TOP (@Limit) LOWER(TransactionID) as TransactionID, RouteId, OperatorId, TestCase, StatusId, TestResultJson, TestResultRawJson -- 'TestType-1' as TestType, CONVERT(varchar(23), [SentTimeUtc], 121) as SentTimeUtc
	FROM gtn.CSG_Log
	WHERE StatusId = @StatusId AND RouteId = @RouteId AND OperatorId = @OperatorId
	ORDER BY CreatedTimeUtc DESC
END

