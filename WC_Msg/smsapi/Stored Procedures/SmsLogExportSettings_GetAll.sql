
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-28
-- Description:	Get all records from SmsLogExportSettings
-- =============================================
CREATE PROCEDURE [smsapi].[SmsLogExportSettings_GetAll]
AS
BEGIN	
	SELECT SubAccountUid
		,MSISDN
		,Body
		,OperatorId
		,OperatorName
	FROM sms.SmsLogExportSettings
END
