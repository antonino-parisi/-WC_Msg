-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-05
-- Description:	Load WhatsApp business management config
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppConfig_GetManagementConfig]
AS
BEGIN
	SELECT 
		ChannelId AS Id,
		AccountUid,
		'Active'AS StatusId,
		Name,
		ServiceId AS BusinessAccountId,
		ServiceTag AS BusinessAccountNamespace,
		PhoneNumber
	FROM ipm.Channel
	WHERE StatusId = 'A' AND ChannelType = 'WA'

END
