
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-09-01
-- =============================================
-- SELECT TOP 1000 * FROM [sms].[vwStatSmsLog] ORDER BY StatEntryId DESC
CREATE VIEW [sms].[vwStatSmsLog]
AS
	SELECT sl.StatEntryId
	  ,CAST(TimeFrom AS date) AS Date
	  ,DATEPART(YEAR, TimeFrom) AS Year
	  ,DATEPART(MONTH, TimeFrom) AS Month
	  ,DATEPART(DAY, TimeFrom) AS Day
      ,DATEPART(HOUR, TimeFrom) AS Hour
      ,sl.TimeFrom
      ,sl.TimeTill
      ,sl.AccountUid, a.AccountId, ISNULL(meta.CustomerType, 'L') AS CustomerType
      ,sl.SubAccountUid, a.SubAccountId
      ,sl.Country
      ,sl.OperatorId, o.OperatorName
      ,sl.SmsTypeId, dst.SmsType
      ,sl.ConnUid, c.ConnId --ISNULL(c.RouteId, '<MISSING>') AS ConnId
      ,sl.CostCurrency
      ,sl.Cost
      ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Cost / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostPerSms
	  ,sl.PriceCurrency
      ,sl.Price
      ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Price / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PricePerSms
	  ,sl.Price - sl.Cost AS Margin
      ,IIF(sl.Cost > 0 AND sl.Price > 0, CAST(100*((sl.Price - sl.Cost) / sl.Price) AS decimal(12,2)), 0) AS MarginRate
      ,CostEUR, CostContract, CostContractCurrency
	  ,PriceEUR, PriceContract, PriceContractCurrency
	  ,sl.PriceEUR - sl.CostEUR AS MarginEUR
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.CostEUR / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostEURPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.CostContract / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostContractPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.PriceEUR / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PriceEURPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.PriceContract / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PriceContractPerSms
	  ,sl.SmsCountTotal
      ,sl.SmsCountTotal - sl.SmsCountRejected AS SmsCountAccepted
      ,sl.SmsCountDelivered
      ,sl.SmsCountUndelivered
      ,sl.SmsCountRejected
      ,sl.SmsCountProcessingWavecell
      ,sl.SmsCountProcessingSupplier
	  ,sl.SmsCountConverted
      ,sl.MsgCountTotal
      ,sl.MsgCountTotal - sl.MsgCountRejected AS MsgCountAccepted
      ,sl.MsgCountDelivered
      ,sl.MsgCountUndelivered
      ,sl.MsgCountRejected
      ,sl.MsgCountProcessingWavecell
      ,sl.MsgCountProcessingSupplier
	  ,sl.MsgCountConverted
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.MsgCountConverted * 100 / (sl.MsgCountTotal - sl.MsgCountRejected), 0) AS ConversionRate
      ,sl.LastUpdatedAt
  FROM sms.StatSmsLog sl WITH (NOLOCK)
	LEFT JOIN sms.DimSmsType dst ON sl.SmsTypeId = dst.SmsTypeId
	LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
	LEFT JOIN dbo.Account a ON sl.SubAccountUid = a.SubAccountUid
	--LEFT JOIN dbo.CarrierConnections c ON sl.ConnUid = c.RouteUid
	LEFT JOIN rt.SupplierConn c ON sl.ConnUid = c.ConnUid
	LEFT JOIN ms.AccountMeta meta ON a.AccountId = meta.AccountId

