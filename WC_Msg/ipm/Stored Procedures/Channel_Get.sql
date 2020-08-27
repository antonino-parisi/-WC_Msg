
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-02-05
-- Description:	Get IPM Channels information for AccountUid
-- =============================================
-- EXEC [ipm].[Channel_Get]	@AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965'
CREATE PROCEDURE [ipm].[Channel_Get]	
	@AccountUid UNIQUEIDENTIFIER
WITH EXECUTE AS OWNER
AS
BEGIN

	OPEN SYMMETRIC KEY ChatAppsConfig_Key  
		DECRYPTION BY CERTIFICATE ChatAppsConfig;

	SELECT 
		ch.ChannelId,
		t.ChannelTypeName AS ChannelType,
		st.[Status],
		ch.[Name],
		ch.Comment,
		ch.AccountName,
		ch.PhoneNumber,
		ch.[Address],
		ch.Email,
		ch.[Description],
		ch.IconUrl,
		ch.AccountUrl,
		ch.ServiceUrl,
		ch.ServiceId,
		CONVERT(VARCHAR(3000), DecryptByKey(ch.ServiceSecret)) AS ServiceSecret,
		ch.ServiceTag,
		ch.WebhookValidationToken,
		ch.OneWayMessaging
	FROM ipm.Channel ch
	JOIN ipm.ChannelType t ON ch.ChannelType = t.ChannelType 
	JOIN ipm.ChannelStatus st ON ch.StatusId = st.StatusId	
	WHERE ch.AccountUid = @AccountUid AND Deleted = 0
	
	CLOSE SYMMETRIC KEY ChatAppsConfig_Key;

END
