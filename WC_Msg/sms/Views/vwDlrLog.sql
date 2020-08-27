


CREATE VIEW [sms].[vwDlrLog]
AS
	SELECT [DlrLogId]
      ,dl.[UMID]
      ,dl.[StatusId], dss.Status, dss.Level as Status_Level, dss.Final as Status_Final
      ,[EventTime]
      ,[Latency]
      ,[Hostname]
	  ,sl.SubAccountId, sl.Country, sl.OperatorId, sl.ConnId, sl.CreatedTime
	  ,DATEPART(YEAR, [EventTime]) AS Year
	  ,DATEPART(MONTH, [EventTime]) AS Month
	  ,DATEPART(DAY, [EventTime]) AS Day
	  ,DATEPART(HOUR, [EventTime]) AS Hour
	  ,DATEPART(MINUTE, [EventTime]) AS Minute
	FROM [sms].[DlrLog] dl
		LEFT JOIN sms.DimSmsStatus dss ON dl.StatusId = dss.StatusId
		LEFT JOIN sms.SmsLog sl ON sl.UMID = dl.UMID
