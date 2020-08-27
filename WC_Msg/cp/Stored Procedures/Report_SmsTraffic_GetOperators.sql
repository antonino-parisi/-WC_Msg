-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- Note: List of ALL operators among used countries by account
-- =============================================
-- EXEC cp.[Report_SmsTraffic_GetOperators] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @TimeframeStart = '2017-01-23 15:00', @TimeframeEnd = '2017-06-09 15:00'
CREATE PROCEDURE [cp].[Report_SmsTraffic_GetOperators]
	@AccountUid uniqueidentifier,
	@TimeframeStart datetime,	-- for future possible usage
	@TimeframeEnd datetime,		-- for future possible usage
	@SubAccountId varchar(50) = NULL	-- optional, for future possible usage
AS
BEGIN

	SELECT DISTINCT cc.Country, c.CountryName, o.OperatorId, o.OperatorName AS OperatorName
	FROM sms.CacheSubaccountCountryLog cc
		INNER JOIN dbo.Account a ON cc.SubAccountUid = a.SubAccountUid
		INNER JOIN cp.Account ca ON ca.AccountId = a.AccountId
		LEFT JOIN mno.Country c ON cc.Country = c.CountryISO2alpha
		INNER JOIN mno.Operator o ON o.CountryISO2alpha = c.CountryISO2alpha
	WHERE ca.AccountUid = @AccountUid AND a.SubAccountId = COALESCE(@SubAccountId, a.SubAccountId)
	ORDER BY c.CountryName ASC, o.OperatorName
END

