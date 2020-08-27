

-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-09-01
-- =============================================
-- SELECT TOP 10 * FROM [sms].[vwStatSmsLog_Last10d]
CREATE VIEW [sms].[vwStatSmsLog_Last10d]
AS
	SELECT CAST(TimeFrom AS date) AS Date
		,DATEPART(YEAR, TimeFrom) AS Year
		,DATEPART(MONTH, TimeFrom) AS Month
		,DATEPART(DAY, TimeFrom) AS Day
		,DATEPART(HOUR, TimeFrom) AS Hour
		,sl.TimeFrom
		,sl.TimeTill
		,a.AccountId, ISNULL(am.CustomerType, 'L') AS CustomerType
		,a.SubAccountId
		,sl.Country
		,sl.OperatorId, o.OperatorName
		,sl.SmsTypeId, dst.SmsType
		,c.ConnId
		,sl.CostCurrency
		,sl.Cost
		,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Cost / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostPerSms
		,sl.PriceCurrency
		,sl.Price
		,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Price / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PricePerSms
		,sl.Price - sl.Cost AS Margin
		,sl.SmsCountTotal
		,sl.SmsCountTotal - sl.SmsCountRejected AS Traffic --SmsCountAccepted
		,sl.SmsCountDelivered
		,sl.SmsCountUndelivered
		,sl.SmsCountRejected
		,sl.SmsCountProcessingWavecell
		,sl.SmsCountProcessingSupplier
		,m.Name AS Manager
		,ISNULL(m.BU, 'Online') AS Team
		--,Team = CASE am.Manager
		--			WHEN 'Mabel Lee' THEN 'Global'
		--			WHEN 'Elliot Drake' THEN 'Global'
		--			WHEN 'Vincent Huys' THEN 'Global'
		--			WHEN 'Petar Migalic' THEN 'Global'
		--			WHEN 'Patrick Valera' THEN 'Global'
		--			WHEN 'Crystal Tian' THEN 'Global'
		--			WHEN 'Gael Tang' THEN 'Global'
		--			WHEN 'Matthieu Fournier' THEN 'Global'
		--			WHEN 'Paul Nam' THEN 'Global'
		--			WHEN 'Ivy Tan' THEN 'Global'
		--			ELSE 'Local'
		--		END
	FROM sms.StatSmsLog sl WITH (NOLOCK)
		LEFT JOIN sms.DimSmsType dst WITH (NOLOCK) ON sl.SmsTypeId = dst.SmsTypeId
		LEFT JOIN mno.Operator o WITH (NOLOCK) ON sl.OperatorId = o.OperatorId
		LEFT JOIN dbo.Account a WITH (NOLOCK) ON sl.SubAccountUid = a.SubAccountUid
		LEFT JOIN rt.SupplierConn c WITH (NOLOCK) ON sl.ConnUid = c.ConnUid
		LEFT JOIN ms.AccountMeta am WITH (NOLOCK) ON a.AccountId = am.AccountId
		LEFT JOIN ms.AccountManager m (NOLOCK) ON am.ManagerId = m.ManagerId
	WHERE sl.TimeFrom >= CAST(DATEADD(DAY, -10, GETUTCDATE()) as date)
		--AND sl.SmsCountTotal > sl.SmsCountRejected


