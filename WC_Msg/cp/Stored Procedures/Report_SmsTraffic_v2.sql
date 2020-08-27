-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[Report_SmsTraffic_v2] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2017-01-23 15:00', @TimeframeEnd = '2017-08-25 15:00'
-- EXEC cp.[Report_SmsTraffic_v2] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2017-07-31 16:00', @TimeframeEnd = '2017-08-14 16:00', @TimeIntervalInMins = 10080
-- EXEC cp.[Report_SmsTraffic_v2] @AccountUid = '4EC250D4-6182-E711-8143-02D85F55FCE7', @TimeframeStart = '2018-10-03 00:00', @TimeframeEnd = '2018-10-05 00:00', @TimeIntervalInMins = 1440, @SubAccountGroupingFlag = 1, @CountryGroupingFlag = 1, @OperatorGroupingFlag = 0
CREATE PROCEDURE [cp].[Report_SmsTraffic_v2]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier = NULL,
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@TimeIntervalInMins smallint = 1440,
	@SubAccountId varchar(50) = NULL,  -- obsolite, use @SubAccountUid
	@SubAccountUid int = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@ShortenStatusId tinyint = NULL,
	@CountryGroupingFlag bit = 0,
	@OperatorGroupingFlag bit = 0,
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

	IF @TimeframeStart < '2017/09/01' SET @TimeframeStart = '2017/09/01'

	DECLARE @ConstRefDate DATETIME = @TimeframeStart -- static value, just for basic of calculations
	--DECLARE @SubAccountUid int = NULL
	IF @SubAccountId IS NOT NULL AND @SubAccountUid IS NULL
		SELECT @SubAccountUid = SubAccountUid FROM ms.SubAccount WHERE SubAccountId = @SubAccountId

	-- Get flag for limiting allowed subaccounts for User
	DECLARE @LimitSubAccounts bit = 0
	SELECT @LimitSubAccounts = cu.LimitSubAccounts
	FROM cp.[User] cu
	WHERE cu.AccountUid = @AccountUid AND cu.UserId = @UserId

	--DECLARE @result TABLE (
	--	TimeIntervalUtc datetime,
	--	AccountUid uniqueidentifier,
	--	SubAccountId varchar(50) NULL,
	--	Country char(2) NULL,
	--	OperatorId int NULL,
	--	PriceCurrency char(3),
	--	Price real,
	--	SmsCountTotal int,
	--	SmsCountDelivered int,
	--	SmsCountTrashed int
	--)
	
	-- use aggregation by date (24h) if interval is >= 24h
	IF @TimeIntervalInMins >= 1440 AND CAST(@TimeframeStart AS time) = '00:00:00'
	BEGIN
		SELECT 
			dbo.fnTimeRounddown(MIN(sl.Date), @TimeIntervalInMins) as TimeIntervalUtc,
			--DATEADD(MINUTE, DATEDIFF(MINUTE, @ConstRefDate, MIN(sl.TimeFrom)) / @TimeIntervalInMins * @TimeIntervalInMins, @ConstRefDate) AS TimeIntervalUtc,
			@AccountUid AS AccountUid,
			CASE WHEN @SubAccountGroupingFlag = 1	THEN sa.SubAccountId	END AS SubAccountId, 
			CASE WHEN @CountryGroupingFlag = 1		THEN sl.Country			END AS Country, 
			CASE WHEN @OperatorGroupingFlag = 1		THEN sl.OperatorId		END AS OperatorId, 
			--sl.OperatorId, 
			--o.OperatorName, o.MCC_Default, o.MNC_Default, 
			--sl.PriceCurrency, ROUND(CAST(SUM(sl.Price) AS DECIMAL(10,3)), 2) AS Cost,
			sa.Currency, 
			CAST(SUM(mno.CurrencyConverter(sl.PriceContract, sl.PriceContractCurrency, sa.Currency, sl.[Date])) AS DECIMAL(20,2)) AS Cost,
			--CAST(mno.CurrencyConverter(SUM(sl.Price), sl.PriceContractCurrency, sa.Currency, @TimeframeStart) AS DECIMAL(10,2)) AS Cost,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal, 0)) AS SmsCountTotal,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountDelivered + sl.SmsCountProcessingSupplier, 0)) AS SmsCountDelivered,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountRejected, 0)) AS SmsCountRejected,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal, 0)) SmsCountOutboundAll,
			SUM(IIF(sl.SmsTypeId=0, sl.SmsCountTotal, 0)) SmsCountInboundAll,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountDelivered + sl.SmsCountProcessingSupplier, 0)) AS SmsCountOutboundDelivered,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountRejected, 0)) AS SmsCountOutboundRejected,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal - sl.SmsCountRejected, 0)) SmsCountOutboundAccepted,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal - sl.SmsCountRejected, 0)) SmsCountCharged
		--SELECT TOP 100 DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins, *
		FROM sms.StatSmsLogDaily sl WITH (NOLOCK) 
			INNER JOIN (
				-- all filters on subaccounts
				SELECT sa.SubAccountUid, sa.SubAccountId, ISNULL(m.Currency, 'EUR') AS Currency
				FROM ms.SubAccount sa WITH (NOLOCK) 
					INNER JOIN cp.Account a WITH (NOLOCK) ON a.AccountUid = sa.AccountUid
					LEFT JOIN ms.AccountMeta m WITH (NOLOCK) ON a.AccountId = m.AccountId
				WHERE sa.AccountUid = @AccountUid
					AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))
					-- filter by allowed subaccounts for user
					AND (@LimitSubAccounts <> 1 OR (@LimitSubAccounts = 1 
						AND EXISTS (SELECT 1 FROM cp.UserSubAccount usa WITH (NOLOCK) WHERE usa.UserId = @UserId AND sa.SubAccountUid = usa.SubAccountUid)))
			) sa ON sa.SubAccountUid = sl.SubAccountUid
			
		WHERE --a.AccountUid = @AccountUid AND
			(sl.Date >= @TimeframeStart AND sl.Date < @TimeframeEnd)
			--AND sl.SmsTypeId = 1 /* MT */
			AND (@Country IS NULL OR (@Country IS NOT NULL AND sl.Country = @Country))
			AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND sl.OperatorId = @OperatorId))
			----AND (@ShortenStatusId IS NULL OR (@ShortenStatusId IS NOT NULL 
			----	AND sl.StatusId IN (SELECT StatusId FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId)))
				
		GROUP BY 
			CASE WHEN @CountryGroupingFlag = 1 THEN sl.Country END,
			CASE WHEN @OperatorGroupingFlag = 1 THEN sl.OperatorId END,
			CASE WHEN @SubAccountGroupingFlag = 1 THEN sa.SubAccountId END,
			sa.Currency,
			DATEDIFF(MINUTE, @ConstRefDate, sl.Date) / @TimeIntervalInMins
		
		ORDER BY 1, 2, 3
	END
	ELSE
	-- use aggregation by 15min if interval is < 24h or shifted from GMT 00:00
	BEGIN
		SELECT 
			dbo.fnTimeRounddown(MIN(sl.TimeFrom), @TimeIntervalInMins) as TimeIntervalUtc,
			--DATEADD(MINUTE, DATEDIFF(MINUTE, @ConstRefDate, MIN(sl.TimeFrom)) / @TimeIntervalInMins * @TimeIntervalInMins, @ConstRefDate) AS TimeIntervalUtc,
			@AccountUid AS AccountUid,
			CASE WHEN @SubAccountGroupingFlag = 1	THEN sa.SubAccountId	END AS SubAccountId, 
			CASE WHEN @CountryGroupingFlag = 1		THEN sl.Country			END AS Country, 
			CASE WHEN @OperatorGroupingFlag = 1		THEN sl.OperatorId		END AS OperatorId, 
			--sl.OperatorId, 
			--o.OperatorName, o.MCC_Default, o.MNC_Default, 
			--sl.PriceCurrency, ROUND(CAST(SUM(sl.Price) AS DECIMAL(10,3)), 2) AS Cost,
			sa.Currency, 
			CAST(SUM(mno.CurrencyConverter(sl.PriceContract, sl.PriceContractCurrency, sa.Currency, sl.TimeFrom)) AS DECIMAL(20,2)) AS Cost,
			--CAST(mno.CurrencyConverter(SUM(sl.Price), sl.PriceContractCurrency, sa.Currency, @TimeframeStart) AS DECIMAL(10,2)) AS Cost,
			SUM(sl.SmsCountTotal) AS SmsCountTotal,
			SUM(sl.SmsCountDelivered + sl.SmsCountProcessingSupplier) AS SmsCountDelivered,
			SUM(sl.SmsCountRejected) AS SmsCountRejected,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal, 0)) SmsCountOutboundAll,
			SUM(IIF(sl.SmsTypeId=0, sl.SmsCountTotal, 0)) SmsCountInboundAll,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountDelivered + sl.SmsCountProcessingSupplier, 0)) AS SmsCountOutboundDelivered,
			SUM(sl.SmsCountRejected) AS SmsCountOutboundRejected,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal - sl.SmsCountRejected, 0)) SmsCountOutboundAccepted,
			SUM(IIF(sl.SmsTypeId=1, sl.SmsCountTotal - sl.SmsCountRejected, 0)) AS SmsCountCharged
		--SELECT TOP 100 DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins, *
		FROM sms.StatSmsLog sl
			INNER JOIN (
				-- all filters on subaccounts
				SELECT sa.SubAccountUid, sa.SubAccountId, ISNULL(m.Currency, 'EUR') Currency
				FROM ms.SubAccount sa WITH (NOLOCK) 
					INNER JOIN cp.Account a WITH (NOLOCK) ON a.AccountUid = sa.AccountUid
					LEFT JOIN ms.AccountMeta m WITH (NOLOCK) ON a.AccountId = m.AccountId
				WHERE sa.AccountUid = @AccountUid
					AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))
					-- filter by allowed subaccounts for user
					AND (@LimitSubAccounts <> 1 OR (@LimitSubAccounts = 1 
						AND EXISTS (SELECT 1 FROM cp.UserSubAccount usa WITH (NOLOCK) WHERE usa.UserId = @UserId AND sa.SubAccountUid = usa.SubAccountUid)))
			) sa ON sa.SubAccountUid = sl.SubAccountUid

		WHERE --sl.AccountUid = @AccountUid AND
			(sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd)
			--AND sl.SmsTypeId = 1 /* MT */
			AND (@Country IS NULL OR (@Country IS NOT NULL AND sl.Country = @Country))
			AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND sl.OperatorId = @OperatorId))
			----AND (@ShortenStatusId IS NULL OR (@ShortenStatusId IS NOT NULL 
			----	AND sl.StatusId IN (SELECT StatusId FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId)))

		GROUP BY 
			CASE WHEN @CountryGroupingFlag = 1 THEN sl.Country END,
			CASE WHEN @OperatorGroupingFlag = 1 THEN sl.OperatorId END,
			CASE WHEN @SubAccountGroupingFlag = 1 THEN sa.SubAccountId END,
			sa.Currency,
			--CAST(sl.CreatedTime as DATE), (DATEPART(HOUR, sl.CreatedTime) * 60 + DATEPART(MINUTE, sl.CreatedTime)) / @TimeIntervalInMins
			DATEDIFF(MINUTE, @ConstRefDate, sl.TimeFrom) / @TimeIntervalInMins

		ORDER BY 1, 2, 3
	END

END
