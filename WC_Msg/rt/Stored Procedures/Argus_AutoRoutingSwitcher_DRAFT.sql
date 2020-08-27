-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-08-05
-- =============================================
CREATE PROCEDURE [rt].[Argus_AutoRoutingSwitcher_DRAFT]
AS
BEGIN
	DECLARE @now DATETIME = SYSUTCDATETIME()

--1. GATHER DR STATISTICS--------------------------------------------------------------------------

	DECLARE @slot INT = 15

	--go back for 30 minutes
	DECLARE @dlrSlot DATETIME = DATEADD(MINUTE, -2 * @slot, @now)
	--make 15min alignment
	set @dlrSlot = DATEADD(MINUTE, -1 * (DATEPART(MINUTE, @dlrSlot) % @slot), @dlrSlot)
	--clear sec and ms
	set @dlrSlot = DATETIMEFROMPARTS(DATEPART(YEAR, @dlrSlot), DATEPART(MONTH, @dlrSlot), DATEPART(DAY, @dlrSlot), DATEPART(HOUR, @dlrSlot), DATEPART(MINUTE, @dlrSlot), 0, 0)

	--debug
	set @dlrSlot = '2017-01-27 07:45:00'

	--calculate other slots
	DECLARE @dlrSlot1 DATETIME = DATEADD(MINUTE, -1 * @slot, @dlrSlot)
	DECLARE @dlrSlot2 DATETIME = DATEADD(MINUTE, -2 * @slot, @dlrSlot)
	DECLARE @dlrSlot3 DATETIME = DATEADD(MINUTE, -3 * @slot, @dlrSlot)

	DECLARE @drStats TABLE (Country CHAR(2), OperatorId INT, ConnUid INT, AcceptedCount INT, DrRate INT, Interval INT)

	INSERT INTO @drStats (Country, OperatorId, ConnUid, AcceptedCount, DrRate, Interval)
	SELECT *
	FROM
	(
		SELECT
		Country, 
		OperatorId, 
		ConnUid, 
		SUM(MsgCountTotal) - SUM(MsgCountRejected) AS AcceptedCount,
		SUM(MsgCountDelivered) * 100/IIF(SUM(MsgCountTotal) = SUM(MsgCountRejected), 1, SUM(MsgCountTotal) - SUM(MsgCountRejected)) AS DrRate,
		@slot AS Interval
		FROM sms.statsmslog sl (NOLOCK)
		WHERE sl.TimeFrom = @dlrSlot
		GROUP BY Country, OperatorId, ConnUid
	) int15
	UNION ALL
	(
		SELECT
		Country, 
		OperatorId, 
		ConnUid, 
		SUM(MsgCountTotal) - SUM(MsgCountRejected) AS AcceptedCnt,
		SUM(MsgCountDelivered) * 100/IIF(SUM(MsgCountTotal) = SUM(MsgCountRejected), 1, SUM(MsgCountTotal) - SUM(MsgCountRejected)) AS DrRate,
		2 * @slot AS Interval
		FROM sms.statsmslog sl (NOLOCK)
		WHERE sl.TimeFrom <= @dlrSlot AND sl.TimeFrom >= @dlrSlot1
		GROUP BY Country, OperatorId, ConnUid
	)
	UNION ALL
	(
		SELECT
		Country, 
		OperatorId, 
		ConnUid, 
		SUM(MsgCountTotal) - SUM(MsgCountRejected) AS AcceptedCnt,
		SUM(MsgCountDelivered) * 100/IIF(SUM(MsgCountTotal) = SUM(MsgCountRejected), 1, SUM(MsgCountTotal) - SUM(MsgCountRejected)) AS DrRate,
		3 * @slot AS Interval
		FROM sms.statsmslog sl (NOLOCK)
		WHERE sl.TimeFrom <= @dlrSlot AND sl.TimeFrom >= @dlrSlot2
		GROUP BY Country, OperatorId, ConnUid
	)
	UNION ALL
	(
		SELECT
		Country, 
		OperatorId, 
		ConnUid, 
		SUM(MsgCountTotal) - SUM(MsgCountRejected) AS AcceptedCnt,
		SUM(MsgCountDelivered) * 100/IIF(SUM(MsgCountTotal) = SUM(MsgCountRejected), 1, SUM(MsgCountTotal) - SUM(MsgCountRejected)) as DrRate,
		4 * @slot AS Interval
		FROM sms.statsmslog sl (NOLOCK)
		WHERE sl.TimeFrom <= @dlrSlot AND sl.TimeFrom >= @dlrSlot3
		GROUP BY Country, OperatorId, ConnUid
	)

	--debug
	SELECT * FROM @drStats

--2. CALCULATE TIER-CONNECTION STATES--------------------------------------------------------------

	DECLARE @tierConnectionState TABLE (TierId INT, ConnUid INT, ScopeId INT, IsOk TINYINT)

	INSERT INTO @tierConnectionState (TierId, ConnUid, ScopeId, IsOk)
	SELECT 
	RoutingTierId, 
	ConnUid,
	ConditionScopeId,
	CASE
		WHEN SUM(IsOk) = COUNT(*) THEN 1
		ELSE 0
	END AS IsOk
	FROM
	(
		SELECT RoutingTierId, ConnUid, ConditionScopeId, IsOk 
		FROM
		(
			--RoutingTierConditionBind rule
			SELECT 
			rt.RoutingTierId,
			rtcon.ConnUid,
			rtc.ConditionScopeId,
			CASE
				WHEN sc.QueueSize > rtcb.QueueSizeMax THEN 0
				WHEN sc.IsConnected = 0 AND rtcb.DowntimeThresholdInSec > 0 AND DATEDIFF(SECOND, sc.UpdatedAt, @now) > rtcb.DowntimeThresholdInSec THEN 0
				ELSE 1
			END AS IsOk
			FROM rt.RoutingTier rt
			JOIN rt.RoutingTierCondition rtc ON rtc.RoutingTierId = rt.RoutingTierId
			JOIN rt.RoutingTierConditionBind rtcb ON  rtc.RoutingTierConditionId = rtcb.RoutingTierConditionId
			JOIN rt.RoutingTierConn rtcon ON rtc.RoutingTierId = rtcon.RoutingTierId
			JOIN rt.SupplierConn sc ON rtcon.ConnUid = sc.ConnUid
			WHERE rt.Deleted = 0 AND rtcon.Deleted = 0
			AND rt.RoutingGroupId = 12198--debug
		) AS bind
		UNION ALL
		(
			--RoutingTierConditionDR rule
			SELECT 
			rt.RoutingTierId,
			rtcon.ConnUid,
			rtc.ConditionScopeId,
			MAX(CASE
				WHEN drs.DrRate < rtcdr.DrRateThreshold THEN 0
				ELSE 1
			END) AS IsOk
			FROM rt.RoutingTier rt
			JOIN rt.RoutingPlanCoverage rpc ON rt.RoutingGroupId = rpc.RoutingGroupId
			JOIN rt.RoutingTierCondition rtc ON rtc.RoutingTierId = rt.RoutingTierId
			join rt.RoutingTierConditionDR rtcdr ON  rtc.RoutingTierConditionId = rtcdr.RoutingTierConditionId
			join rt.RoutingTierConn rtcon ON rtc.RoutingTierId = rtcon.RoutingTierId
			join @drStats drs ON drs.ConnUid = rtcon.ConnUid AND drs.Country = rpc.Country AND drs.OperatorId = rpc.OperatorId
				AND (rtcdr.TimeframeInMin = 0 OR (rtcdr.TimeframeInMin > 0 AND drs.Interval = rtcdr.TimeframeInMin)) 
				AND (rtcdr.MinSmsVolume = 0 OR (rtcdr.MinSmsVolume > 0 AND drs.AcceptedCount >= rtcdr.MinSmsVolume))
			WHERE rt.Deleted = 0 AND rtcon.Deleted = 0
			AND rt.RoutingGroupId = 12198--debug
			GROUP BY rt.RoutingTierId, rtcon.ConnUid, rtc.ConditionScopeId
		)
	) aggr
	GROUP BY RoutingTierId, ConnUid, ConditionScopeId

	--debug
	SELECT * FROM @tierConnectionState

--3. CONNECTION SCOPE = 1 - UPDATE CONNECTIONS-----------------------------------------------------

	UPDATE rtc
	SET rtc.Active = tcs.IsOk
	FROM rt.RoutingTierConn rtc
	JOIN @tierConnectionState tcs ON rtc.RoutingTierId = tcs.TierId and rtc.ConnUid = tcs.ConnUid
	WHERE ScopeId = 1 AND rtc.Active != tcs.IsOk

--4. TIER SCOPE = 2 - UPDATE CONNECTIONS-----------------------------------------------------------

	UPDATE rtc
	SET rtc.Active = tiers.IsOk
	FROM rt.RoutingTierConn rtc
	JOIN
	(
		SELECT 
		TierId,  
		CASE
			WHEN SUM(IsOk) = COUNT(*) THEN 1
			ELSE 0
		END as IsOk
		FROM @tierConnectionState
		WHERE ScopeId = 2
		GROUP BY TierId
	) tiers ON rtc.RoutingTierId = tiers.TierId
	WHERE rtc.Active != tiers.IsOk

--5. UPDATE CURRENT LEVEL FOR GROUP----------------------------------------------------------------

	UPDATE rg 
	SET TierLevelCurrent = newLevels.MinActiveLevel
	FROM rt.RoutingGroup rg
	JOIN
	(
		SELECT rt.RoutingGroupId, MIN(rt2.TierLevel) AS MinActiveLevel FROM
		rt.RoutingTier rt
		JOIN (SELECT DISTINCT TierId FROM @tierConnectionState) AS affected ON rt.RoutingTierId = affected.TierId
		JOIN rt.RoutingTier rt2 on rt2.RoutingGroupId = rt.RoutingGroupId
		JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt2.RoutingTierId
		WHERE rt2.Deleted = 0 AND rtc.Deleted = 0 AND rtc.Active = 1
		GROUP BY rt.RoutingGroupId
	) newLevels ON newLevels.RoutingGroupId = rg.RoutingGroupId
	WHERE TierLevelCurrent != newLevels.MinActiveLevel
END
