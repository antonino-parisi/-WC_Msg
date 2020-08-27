
-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-07-23
-- =============================================
-- SAMPLE:
-- EXEC cp.Report_UrlShorten_Data @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @UserId = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2018-07-22', @TimeframeEnd = '2018-07-23'
CREATE PROCEDURE [cp].[Report_UrlShorten_Data]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@SubAccountUid int = NULL,
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@TimeIntervalInMins smallint = 1440,
	@Offset int = 0,
	@Limit int = 100
	--@OutputTotals bit = 0
AS
BEGIN

	--DECLARE @AccountUid uniqueidentifier = '619250fe-e2e5-e611-813f-06b9b96ca965'
	--DECLARE @TimeframeStart datetime = '2017-01-23 15:00'
	--DECLARE @TimeframeEnd datetime= '2017-08-25 15:00'
	--DECLARE @SubAccountId varchar(50) = NULL
	--DECLARE @TimeIntervalInMins smallint = 1440

	--IF @TimeframeStart < '2017/09/01' SET @TimeframeStart = '2017/09/01'

	-- access check
	--EXEC cp.User_CheckPermissions @AccountUid = @AccountUid, @UserId = @UserId, @SubAccountUid = @SubAccountUid

	-- validate params
	IF @Limit < 1 SET @Limit = 1
	IF @Limit > 100 OR @Limit IS NULL SET @Limit = 100

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
		@AccountUid AS AccountUid,
		sa.SubAccountId,
		b.BaseUrl,
		b.BaseUrlId,
		SUM(sl.MsgTotal) AS MsgTotal,
		SUM(sl.MsgDelivered) AS MsgDelivered,
		SUM(sl.UrlCreated) AS UrlCreated,
		SUM(sl.UrlClicked) AS UrlClicked
	--SELECT TOP 100 DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins, *
	FROM sms.StatUrlShorten sl
		INNER JOIN sms.UrlShortenBaseUrl b ON sl.BaseUrlId = b.BaseUrlId
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

	WHERE (sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd)
	
	GROUP BY 
		DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins,
		sa.SubAccountId,
		b.BaseUrl,
		b.BaseUrlId

	ORDER BY TimeIntervalUtc, SubAccountId, BaseUrl
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY;
	
	-- returns totals
	--IF @OutputTotals = 1

END
