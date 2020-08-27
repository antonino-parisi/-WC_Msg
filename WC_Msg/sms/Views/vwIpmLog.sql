CREATE VIEW [sms].[vwIpmLog]
AS
	SELECT UMID
		,ipm.SubAccountUid, sa.SubAccountId, a.AccountId
		,ipm.ChannelUid AS ChannelTypeId, chn.ChannelType, chn.ChannelTypeName, 
		ipm.ChannelUserId,
		ipm.Direction, ipm.Step, ipm.InitSession
		,ipm.[StatusId], dss.ShortenStatusName AS Status
		,ipm.Country, c.CountryName, ipm.MSISDN
		,ipm.[ContentTypeId], dct.ContentType, [Content]
		,ipm.CreatedAt, ipm.DeliveredAt, ipm.ReadAt,
		ipm.UpdatedAt
		,[ConnMessageId], [ConnErrorCode]
		,[ChannelCostEUR], [ChannelCostContract]
		,[MessageFeeEUR], [MessageFeeContract], [ContractCurrency]
		,[ClientMessageId], [ClientBatchId], [BatchId]
		,DATEPART(YEAR, ipm.CreatedAt) AS Year
		,DATEPART(MONTH, ipm.CreatedAt) AS Month
		,DATEPART(DAY, ipm.CreatedAt) AS Day
		,DATEPART(HOUR,	ipm.CreatedAt) AS Hour
		,DATEPART(MINUTE, ipm.CreatedAt) AS Minute
  FROM [sms].[IpmLog] ipm WITH (NOLOCK)
	LEFT JOIN sms.DimContentType dct ON ipm.ContentTypeId = dct.ContentTypeId
	LEFT JOIN sms.DimSmsStatus dss ON ipm.StatusId = dss.StatusId
	LEFT JOIN mno.Country c ON ipm.Country = c.CountryISO2alpha
	LEFT JOIN ms.SubAccount sa ON ipm.SubAccountUid = sa.SubAccountUid
	LEFT JOIN cp.Account a ON sa.AccountUid = a.AccountUid
	LEFT JOIN ipm.ChannelType chn ON ipm.ChannelUid = chn.ChannelTypeId
