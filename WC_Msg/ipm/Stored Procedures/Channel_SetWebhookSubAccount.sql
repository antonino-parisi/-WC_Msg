
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-12
-- Description:	Update IPM Channel
-- =============================================
CREATE PROCEDURE [ipm].[Channel_SetWebhookSubAccount]	
	@ChannelId UNIQUEIDENTIFIER,
	@SubAccountUid INT
AS
BEGIN

	DECLARE @AccountUid UNIQUEIDENTIFIER;
	SET @AccountUid = (SELECT TOP 1 AccountUid FROM ms.SubAccount WHERE SubAccountUid = @SubAccountUid)

	UPDATE ipm.Channel
	   SET WebhookSubAccountUid = @SubAccountUid
	WHERE ChannelId = @ChannelId AND AccountUid = @AccountUid;
	
END
