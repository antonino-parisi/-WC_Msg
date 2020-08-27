-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-07-23
-- =============================================
-- SAMPLE:
-- EXEC cp.Report_UrlShorten @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @UserId = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2018-07-22', @TimeframeEnd = '2018-07-23'
CREATE PROCEDURE [cp].[Report_UrlShorten]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@SubAccountUid int = NULL,
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@TimeIntervalInMins smallint = 1440,
	--@Country char(2) = NULL,
	--@OperatorId int = NULL,
	--@CountryGroupingFlag bit = 0,
	--@OperatorGroupingFlag bit = 0,
	@SubAccountGroupingFlag bit = 0
AS
BEGIN

	--DECLARE @AccountUid uniqueidentifier = '619250fe-e2e5-e611-813f-06b9b96ca965'
	--DECLARE @TimeframeStart datetime = '2017-01-23 15:00'
	--DECLARE @TimeframeEnd datetime= '2017-08-25 15:00'
	--DECLARE @SubAccountId varchar(50) = NULL
	--DECLARE @TimeIntervalInMins smallint = 1440
	--DECLARE @CountryGroupingFlag bit = 0
	--DECLARE @OperatorGroupingFlag bit = 0
	--DECLARE @SubAccountGroupingFlag bit = 0
	--DECLARE @Country char(2) = NULL
	--DECLARE @OperatorId int = NULL
	--DECLARE @ShortenStatusId tinyint = NULL

	--IF @TimeframeStart < '2017/09/01' SET @TimeframeStart = '2017/09/01'

	DECLARE @ConstRefDate DATETIME = @TimeframeStart -- static value, just for basic of calculations
	
	--DECLARE @SubAccountUid int = NULL
	--IF @SubAccountId IS NOT NULL
	--	SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId

	-- Get flag for limiting allowed subaccounts for User
	DECLARE @LimitSubAccounts bit = 0
	SELECT @LimitSubAccounts = cu.LimitSubAccounts
	FROM cp.[User] cu
	WHERE cu.AccountUid = @AccountUid AND cu.UserId = @UserId

	-- Main select
	SELECT 
		dbo.fnTimeRountdown(MIN(sl.TimeFrom), @TimeIntervalInMins) as TimeIntervalUtc,
		--DATEADD(MINUTE, DATEDIFF(MINUTE, @ConstRefDate, MIN(sl.TimeFrom)) / @TimeIntervalInMins * @TimeIntervalInMins, @ConstRefDate) AS TimeIntervalUtc,
		@AccountUid AS AccountUid,
		CASE WHEN @SubAccountGroupingFlag = 1	THEN sa.SubAccountId	END AS SubAccountId, 
		--CASE WHEN @CountryGroupingFlag = 1		THEN sl.Country			END AS Country, 
		--CASE WHEN @OperatorGroupingFlag = 1		THEN sl.OperatorId		END AS OperatorId, 
		--sl.OperatorId, 
		--o.OperatorName, o.MCC_Default, o.MNC_Default, 
		SUM(sl.MsgTotal) AS MsgTotal,
		SUM(sl.MsgDelivered) AS MsgDelivered,
		SUM(sl.UrlCreated) AS UrlCreated,
		SUM(sl.UrlClicked) AS UrlClicked
	--SELECT TOP 100 DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins, *
	FROM sms.StatUrlShorten sl
		INNER JOIN (
			-- all filters on subaccounts
			SELECT sa.SubAccountUid, sa.SubAccountId
			FROM dbo.Account sa
				INNER JOIN cp.Account a ON a.AccountId = sa.AccountId
			WHERE a.AccountUid = @AccountUid
				AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))
				-- filter by allowed subaccounts for user
				AND (@LimitSubAccounts <> 1 OR (@LimitSubAccounts = 1 
					AND EXISTS (SELECT 1 FROM cp.UserSubAccount usa WHERE usa.UserId = @UserId AND sa.SubAccountUid = usa.SubAccountUid)))
		) sa ON sa.SubAccountUid = sl.SubAccountUid

	WHERE --sl.AccountUid = @AccountUid AND
		(sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd)
		/* TODO: rewrite filters to dynamic query */
		--AND (@Country IS NULL OR (@Country IS NOT NULL AND sl.Country = @Country))
		--AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND sl.OperatorId = @OperatorId))
		----AND (@ShortenStatusId IS NULL OR (@ShortenStatusId IS NOT NULL 
		----	AND sl.StatusId IN (SELECT StatusId FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId)))

	GROUP BY 
		--CASE WHEN @CountryGroupingFlag = 1 THEN sl.Country END,
		--CASE WHEN @OperatorGroupingFlag = 1 THEN sl.OperatorId END,
		CASE WHEN @SubAccountGroupingFlag = 1 THEN sa.SubAccountId END,
		--CAST(sl.CreatedTime as DATE), (DATEPART(HOUR, sl.CreatedTime) * 60 + DATEPART(MINUTE, sl.CreatedTime)) / @TimeIntervalInMins
		DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins

	ORDER BY 1, 2, 3
END
