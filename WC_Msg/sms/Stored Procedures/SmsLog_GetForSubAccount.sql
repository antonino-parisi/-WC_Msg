-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-19
-- Description:	Export SMS Logs for SubAccount
-- =============================================
CREATE PROCEDURE [sms].[SmsLog_GetForSubAccount]
	@SubAccountUid int,
	@FromTime datetime,
	@ToTime datetime,	
	@PageSize int,
	@Page int
WITH EXECUTE AS 'dbo'
AS
BEGIN

	IF @Page < 1 SET @Page = 1
	
	-- temporary, while INDEX is on SubAccountId column
	DECLARE @SubAccountId varchar(50)
	SELECT @SubAccountId =  SubAccountId FROM ms.SubAccount WHERE SubAccountUid = @SubAccountUid

	SELECT Umid
		,ClientMessageId
		,BatchId
		,ClientBatchId
		,Country
		,Body AS MessageBody
		,CreatedTime AS SubmittedAt
		,MSISDN
		,lg.OperatorId
		,o.OperatorName
		,Price * SegmentsReceived AS Price
		,PriceCurrency AS Currency
		,[Source]
		,dss.ShortenStatusName AS [Status]
		,det.EncodingType AS [Encoding]
		-- ,ConnErrorCode AS ErrorCode
		,conn.ConnectionType AS [Endpoint]
		,SegmentsReceived AS Segments
		,dst.SmsType AS [Type]
	FROM sms.SmsLog AS lg (NOLOCK)
		LEFT JOIN sms.DimSmsStatus dss ON lg.StatusId = dss.StatusId
		LEFT JOIN sms.DimEncodingType det ON lg.EncodingTypeId = det.EncodingTypeId
		LEFT JOIN sms.DimSmsType dst ON lg.SmsTypeId = dst.SmsTypeId
		LEFT JOIN mno.Operator o ON lg.OperatorId = o.OperatorId
		LEFT JOIN sms.DimConnType conn ON lg.ConnTypeId = conn.ConnTypeId		
	WHERE lg.SubAccountId = @SubAccountId AND lg.CreatedTime >= @FromTime AND lg.CreatedTime < @ToTime
	ORDER BY lg.CreatedTime
	OFFSET (@Page - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY
END
