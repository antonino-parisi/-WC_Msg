CREATE PROCEDURE rt.RoutingCoverageConditionStatus_LoadAll
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
		rccs.SubAccountUid, 
		rccs.TierEntryId, 
		rccs.Country, 
		rccs.OperatorId, 
		rccs.FlagBindUptime,
		rccs.FlagBindQueue, 
		rccs.FlagDlr, 
		rccs.FlagLatency,
		rccs.FlagMargin,
		rccs.DlrRate,
		rccs.Latency,
		rccs.MarginRate
	FROM rt.RoutingCoverageConditionStatus rccs
	WHERE (@LastSyncTimestamp IS NOT NULL AND rccs.LastUpdatedAt >= @LastSyncTimestamp)
END
