
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-02-13
-- Description:	Update Service info for Channel recrod
-- =============================================
CREATE PROCEDURE [ipm].[Channel_UpdateServiceInfo]
	@ChannelId uniqueidentifier,
	@ServiceUrl varchar(1024),
	@ServiceId varchar(200),
	@ServiceSecret varchar(3000),
	@ServiceTag varchar(1024),
	@WebhookValidationToken varchar(36),
	@OneWayMessaging bit
WITH EXECUTE AS OWNER
AS
BEGIN
  
    DECLARE @SecretEncrypted VARBINARY(6000);
	OPEN SYMMETRIC KEY ChatAppsConfig_Key  
		DECRYPTION BY CERTIFICATE ChatAppsConfig;
		SET @SecretEncrypted = EncryptByKey(Key_GUID('ChatAppsConfig_Key'), @ServiceSecret)	
	CLOSE SYMMETRIC KEY ChatAppsConfig_Key;

	UPDATE ipm.Channel
		SET ServiceUrl = @ServiceUrl,
			ServiceId = @ServiceId,
			ServiceSecret = @SecretEncrypted,
			ServiceTag = @ServiceTag,
			WebhookValidationToken = @WebhookValidationToken,
			OneWayMessaging = @OneWayMessaging
	WHERE ChannelId = @ChannelId

END
