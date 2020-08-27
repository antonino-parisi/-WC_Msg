
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-09-18
-- =============================================
-- SELECT TOP 100 * FROM [sms].[vwStatSmsLogDaily] ORDER BY StatEntryId DESC
CREATE VIEW [sms].[vwStatSmsLogDaily]
AS
	SELECT sl.StatEntryId
	  ,DATEPART(YEAR, sl.Date) AS Year
	  ,DATEPART(MONTH, sl.Date) AS Month
	  ,DATEPART(DAY, sl.Date) AS Day
      ,sl.Date
      ,sl.AccountUid, a.AccountId, 
	  ISNULL(meta.CustomerType, 'L') AS CustomerType,
	  ISNULL(meta.Currency, 'EUR') AS ContractCurrency
      ,sl.SubAccountUid, sa.SubAccountId
      ,sl.Country, cc.CountryName
      ,sl.OperatorId, o.OperatorName
      ,sl.SmsTypeId, dst.SmsType
      ,sl.ConnUid
	  ,c.ConnId AS ConnId /* + IIF(c.Deleted = 0, '', ' <DELETED>') removed to allow other joins */ 
      -- money total
	  ,sl.CostCurrency
      ,sl.Cost
      ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Cost / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostPerSms
	  ,sl.PriceCurrency
      ,sl.Price
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.Price / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PricePerSms
	  ,sl.Price - sl.Cost AS Margin
	  ,IIF(sl.Price > 0, CAST(100*((sl.Price - sl.Cost) / sl.Price) AS decimal(12,2)), 0) AS MarginRate
      ,CostEUR, CostContract, CostContractCurrency
	  ,PriceEUR, PriceContract, PriceContractCurrency
	  ,sl.PriceEUR - sl.CostEUR AS MarginEUR
	  -- money per SMS
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.CostEUR / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostEURPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.CostContract / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS CostContractPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.PriceEUR / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PriceEURPerSms
	  ,IIF(sl.SmsCountTotal - sl.SmsCountRejected > 0, sl.PriceContract / (sl.SmsCountTotal - sl.SmsCountRejected), NULL) AS PriceContractPerSms
	  --volumes
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
  FROM sms.StatSmsLogDaily sl WITH (NOLOCK)
	LEFT JOIN sms.DimSmsType dst ON sl.SmsTypeId = dst.SmsTypeId
	LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
	LEFT JOIN ms.SubAccount sa ON sl.SubAccountUid = sa.SubAccountUid
	LEFT JOIN cp.Account a ON sl.AccountUid = a.AccountUid
	LEFT JOIN ms.AccountMeta meta ON a.AccountId = meta.AccountId
	--LEFT JOIN dbo.CarrierConnections c ON sl.ConnUid = c.RouteUid
	LEFT JOIN rt.SupplierConn c ON sl.ConnUid = c.ConnUid
	LEFT JOIN mno.Country cc ON sl.Country = cc.CountryISO2alpha
