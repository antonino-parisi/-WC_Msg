-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-28
-- =============================================
-- EXEC map.[RoutingTierCondition_GetAllByTier] @RoutingTierId = 1219
CREATE PROCEDURE [map].[RoutingTierCondition_GetAllByTier]
	@RoutingTierId int		-- filter
AS
BEGIN

	--DECLARE @RoutingTierId int = 1219

	SELECT rtc.RoutingTierConditionId, rtc.RoutingTierId, 
		rtc.ConditionTypeId, t.ConditionTypeName, rtc.ConditionScopeId, s.ConditionScopeName AS ConditionScopeName
	FROM rt.RoutingTierCondition rtc
		LEFT JOIN rt.RoutingTierConditionType t ON rtc.ConditionTypeId = t.ConditionTypeId
		LEFT JOIN rt.RoutingTierConditionScope s ON rtc.ConditionScopeId = s.ConditionScopeId
	WHERE rtc.RoutingTierId = @RoutingTierId

	-- bind-status & bind-queue 
	SELECT RoutingTierConditionId, /*RoutingTierId, ConditionTypeId, ScopeTypeId, */ParamName, ParamValue
	FROM (
		SELECT rtc.RoutingTierConditionId, rtc.RoutingTierId, --rtc.ConditionTypeId, rtc.ScopeTypeId,
			CAST('BIND' AS varchar(10)) AS ConditionType,
			CAST(b.DowntimeThresholdInSec AS varchar(10))	AS DowntimeThresholdInSec, 
			CAST(b.QueueSizeMax AS varchar(10))				AS QueueSizeMax
		FROM rt.RoutingTierCondition rtc
			JOIN rt.RoutingTierConditionBind b ON rtc.RoutingTierConditionId = b.RoutingTierConditionId
		WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.ConditionTypeId = 1 /* BIND */
		) t
		UNPIVOT ( ParamValue FOR ParamName IN (ConditionType, DowntimeThresholdInSec, QueueSizeMax)) AS unpvt
	UNION ALL
	---- bind queue size
	--SELECT RoutingTierConditionId, RoutingTierId, ConditionTypeId, ScopeTypeId, ParamName, ParamValue
	--FROM (
	--	SELECT rtc.RoutingTierConditionId, rtc.RoutingTierId, rtc.ConditionTypeId, rtc.ScopeTypeId,
	--		b.QueueSizeMax
	--	FROM rt.RoutingTierCondition rtc
	--		JOIN rt.RoutingTierConditionBindQueue b ON rtc.RoutingTierConditionId = b.RoutingTierConditionId
	--	WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.ConditionTypeId = 2 /* bind-queue */
	--	) t
	--	UNPIVOT ( ParamValue FOR ParamName IN (t.QueueSizeMax)) AS unpvt
	--UNION ALL
	--	dr-rate & dr-latency
	SELECT RoutingTierConditionId, /*RoutingTierId, ConditionTypeId, ScopeTypeId, */ ParamName, ParamValue
	FROM (
		SELECT rtc.RoutingTierConditionId, rtc.RoutingTierId, --rtc.ConditionTypeId, rtc.ScopeTypeId,
			CAST('DR' AS varchar(10)) AS ConditionType,
			CAST(d.DrRateThreshold AS varchar(10))		AS DrRateThreshold, 
			CAST(d.DrLatencyThresholdInMin AS varchar(10))	AS DrLatencyThresholdInMin, 
			CAST(d.MinSmsVolume AS varchar(10))			AS MinSmsVolume,
			CAST(d.TimeframeInMin AS varchar(10))		AS TimeframeInMin
		FROM rt.RoutingTierCondition rtc
			JOIN rt.RoutingTierConditionDR d ON rtc.RoutingTierConditionId = d.RoutingTierConditionId
		WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.ConditionTypeId = 2 /* DR */
		) t
		UNPIVOT ( ParamValue FOR ParamName IN (ConditionType, DrRateThreshold, DrLatencyThresholdInMin, MinSmsVolume, TimeframeInMin)) AS unpvt
	UNION ALL
	--	dr-rate & dr-latency
	SELECT RoutingTierConditionId, /*RoutingTierId, ConditionTypeId, ScopeTypeId, */ ParamName, ParamValue
	FROM (
		SELECT rtc.RoutingTierConditionId, rtc.RoutingTierId, --rtc.ConditionTypeId, rtc.ScopeTypeId,
			CAST('MARGIN' AS varchar(10)) AS ConditionType,
			CAST(m.MarginThresholdMin AS varchar(10))	AS MarginThresholdMin, 
			--CAST(m.MinSmsVolume AS varchar(10))		AS MinSmsVolume,
			CAST(m.TimeframeInMin AS varchar(10))		AS TimeframeInMin
		FROM rt.RoutingTierCondition rtc
			JOIN rt.RoutingTierConditionMargin m ON rtc.RoutingTierConditionId = m.RoutingTierConditionId
		WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.ConditionTypeId = 3 /* MARGIN */
		) t
		UNPIVOT ( ParamValue FOR ParamName IN (ConditionType, MarginThresholdMin, TimeframeInMin)) AS unpvt

END
