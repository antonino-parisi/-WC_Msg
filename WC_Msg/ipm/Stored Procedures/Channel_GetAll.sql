-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-16
-- Description:	Get IPM Channels information
-- =============================================
CREATE PROCEDURE [ipm].[Channel_GetAll]	
WITH EXECUTE AS OWNER
AS
BEGIN

	OPEN SYMMETRIC KEY ChatAppsConfig_Key  
		DECRYPTION BY CERTIFICATE ChatAppsConfig;

	SELECT 
		ch.ChannelId,
		t.ChannelTypeName AS ChannelType,
		ch.[Name],
		ch.ServiceUrl,
		ch.ServiceId,
		CONVERT(VARCHAR(3000), DecryptByKey(ch.ServiceSecret)) AS ServiceSecret,
		ch.ServiceTag,
		ch.WebhookValidationToken,
		ch.WebhookSubAccountUid,
		ch.OneWayMessaging
	FROM ipm.Channel ch
	JOIN ipm.ChannelType t ON ch.ChannelType = t.ChannelType
	WHERE Deleted = 0 AND StatusId = 'A'
	
	CLOSE SYMMETRIC KEY ChatAppsConfig_Key;

END
