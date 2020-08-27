-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-28
-- =============================================
-- EXEC map.RoutingTierCondition_SetParam @RoutingTierConditionId = 1, @ParamName = 'DowntimeThresholdInSec', @ParamValue = '60'
CREATE PROCEDURE [map].[RoutingTierCondition_SetParam]
	@RoutingTierConditionId int,
	@ParamName varchar(50),
	@ParamValue varchar(50)
AS
BEGIN
	
	DECLARE @ConditionTypeId int

	SELECT @ConditionTypeId = ConditionTypeId 
	FROM rt.RoutingTierCondition 
	WHERE RoutingTierConditionId = @RoutingTierConditionId
	
	-- Note: Ugly implementaion. I don't like it :(((((   Anton.
	IF @ConditionTypeId = 1 -- BIND
	BEGIN
		UPDATE rt.RoutingTierConditionBind
		SET DowntimeThresholdInSec = CAST(@ParamValue AS int)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'DowntimeThresholdInSec'

		UPDATE rt.RoutingTierConditionBind
		SET QueueSizeMax = IIF(@ParamValue <> '', CAST(@ParamValue AS int), NULL)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'QueueSizeMax'
	END
	ELSE IF @ConditionTypeId = 2 -- DR
	BEGIN
		UPDATE rt.RoutingTierConditionDR
		SET TimeframeInMin = CAST(@ParamValue AS smallint)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'TimeframeInMin'

		UPDATE rt.RoutingTierConditionDR
		SET MinSmsVolume = CAST(@ParamValue AS int)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'MinSmsVolume'
		
		UPDATE rt.RoutingTierConditionDR
		SET DrRateThreshold = CAST(@ParamValue AS tinyint)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'DrRateThreshold'
		
		UPDATE rt.RoutingTierConditionDR
		SET DrLatencyThresholdInMin = CAST(@ParamValue AS smallint)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'DrLatencyThresholdInMin'
	END
	ELSE IF @ConditionTypeId = 3 -- MARGIN
	BEGIN
		UPDATE rt.RoutingTierConditionMargin
		SET TimeframeInMin = CAST(@ParamValue AS smallint)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'TimeframeInMin'

		UPDATE rt.RoutingTierConditionMargin
		SET MarginThresholdMin = CAST(@ParamValue AS tinyint)
		WHERE RoutingTierConditionId = @RoutingTierConditionId AND @ParamName = 'MarginThresholdMin'
	END
END
