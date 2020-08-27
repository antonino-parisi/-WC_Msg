---- =============================================
---- Author:		Shchekalov Anton
---- Create date: 2017-05-19
---- =============================================
---- EXEC cp.[Report_SmsTraffic_OperatorsSummary_v2] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2017-01-23 15:00', @TimeframeEnd = '2017-06-09 15:00'
CREATE PROCEDURE [cp].[Report_SmsTraffic_OperatorsSummary]
	@AccountUid uniqueidentifier,
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@SubAccountId varchar(50) = NULL,	-- obsolite, use @SubAccountUid
	@SubAccountUid int = NULL
AS
BEGIN

	--DECLARE @AccountUid uniqueidentifier
	--DECLARE @SubAccountId varchar(50) = NULL
	--DECLARE @TimeframeStart datetime = '2017-06-23 15:00'
	--DECLARE @TimeframeEnd datetime = '2017-08-09 15:00'
	--DECLARE @ConstRefDate DATETIME = @TimeframeStart -- static value, just for basic of calculations

	--DECLARE @SubAccountUid int = NULL
	IF @SubAccountUid IS NULL AND @SubAccountId IS NOT NULL
		SELECT @SubAccountUid = SubAccountUid FROM ms.SubAccount WHERE SubAccountId = @SubAccountId

	SELECT
		sl.Country, c.CountryName, 
		sl.OperatorId, o.OperatorName,
		ROW_NUMBER() OVER (PARTITION BY sl.Country ORDER BY SUM(sl.SmsCountTotal) DESC) AS RankInCountry,
		--ISNULL(sl.Country, '--') AS Country, 
		--ISNULL(sl.OperatorId, 0) AS OperatorId, ISNULL(o.OperatorName, '--') AS OperatorName,
		sl.PriceContractCurrency AS PriceCurrency, 
		ROUND(SUM(sl.PriceContract), 2) AS Price,
		ROUND(SUM(sl.PriceEUR), 2) AS PriceEUR,
		SUM(sl.SmsCountTotal) as SmsCountTotal,
		SUM(sl.SmsCountDelivered) AS SmsCountDelivered,
		SUM(sl.SmsCountRejected) AS SmsCountTrashed
	FROM sms.StatSmsLog sl
		--INNER JOIN dbo.Account sa ON sa.SubAccountUid = sa.SubAccountUid
		LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c ON sl.Country = c.CountryISO2alpha
	WHERE
		sl.AccountUid = @AccountUid
		AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sl.SubAccountUid = @SubAccountUid))
		AND sl.SmsTypeId = 1 /* MT */
		AND (sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd)
	GROUP BY
		sl.Country, sl.OperatorId,
		c.CountryName, o.OperatorName, 
		sl.PriceContractCurrency
	HAVING SUM(sl.SmsCountTotal) > SUM(sl.SmsCountRejected)
	ORDER BY Country, SmsCountTotal DESC
	
END
