CREATE VIEW [sms].[vwSmsLog]
AS
	SELECT 
		[UMID]
      ,sl.[SubAccountId], sl.SubAccountUid, a.AccountId
      ,sc.ConnId + IIF(sc.Deleted = 0, '', ' <DELETED>') AS ConnId
	  ,sl.ConnUid
      ,sl.[SmsTypeId], dst.SmsType
      ,sl.[Country], c.CountryName
      ,sl.[OperatorId], o.OperatorName
      ,sl.[StatusId], dss.Status, dss.Final as Status_Final, dss.Level as Status_Level
      ,[MSISDN]
      ,[SourceOriginal]
      ,[Source]
      ,[BodyOriginal]
      ,[Body]
      ,sl.[EncodingTypeId], det.EncodingType
      ,sl.[DCS], dd.CharacterSetText, dd.MessageClassText
      ,[CreatedTime]
      ,[UpdatedTime]
      ,sl.[ConnTypeId], dct.ConnectionType
      ,[ConnMessageId]
      ,[ConnErrorCode]
      ,[AdditionalInfo]
      ,[Cost]
      ,[CostCurrency]
      ,[Price]
      ,[PriceCurrency]
	  ,CostEURPerSms, CostContractPerSms, CostContractCurrency
	  ,PriceEURPerSms, PriceContractPerSms, PriceContractCurrency
      ,[SegmentsReceived]
      --,[SegmentsSent]
      --,[SegmentsDelivered]
      ,[ClientMessageId]
      ,[ClientBatchId]
      ,[BatchId]
      ,[ClientDeliveryRequested]
      --,[ScheduledTime]
      ,[ExpiryTime]
	  ,DATEPART(YEAR, [CreatedTime]) AS Year
	  ,DATEPART(MONTH, [CreatedTime]) AS Month
	  ,DATEPART(DAY, [CreatedTime]) AS Day
	  ,DATEPART(HOUR, [CreatedTime]) AS Hour
	  ,DATEPART(MINUTE, [CreatedTime]) AS Minute
  FROM [sms].[SmsLog] sl (NOLOCK)
	LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
	LEFT JOIN sms.DimSmsStatus dss ON sl.StatusId = dss.StatusId
	LEFT JOIN sms.DimSmsType dst ON sl.SmsTypeId = dst.SmsTypeId
	LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId
	LEFT JOIN sms.DimDCS dd ON sl.DCS = dd.DCS
	LEFT JOIN mno.Country c ON sl.Country = c.CountryISO2alpha
	LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
	LEFT JOIN dbo.Account a ON sl.SubAccountId = a.SubAccountId
	LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = sl.ConnUid
