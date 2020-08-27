-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-07-30
-- Description:	Get IPM record
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 22/07/2020  Igor     Added ChannelID parameter
CREATE PROCEDURE [sms].[IpmLog_Get]
	@UMID uniqueidentifier = NULL,
	@ChannelId uniqueidentifier = NULL, -- TODO: will be replaced to mandatory field, after full MessageSphere deployment
    @ChannelUid tinyint,
    @ConnMessageId varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @UMID IS NOT NULL
	BEGIN
		SELECT 
			il.UMID, 
			il.MSISDN, 
			il.ChannelUserId, 
			il.ClientMessageId, 
			il.ClientBatchId, 
			cb.CallbackUrl, 
			il.SubAccountUid,
			il.ChannelId,
			ct.ContentType
		FROM sms.IpmLog il WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON il.UMID = cb.UMID
			INNER JOIN sms.DimContentType ct on ct.ContentTypeId = il.ContentTypeId
		WHERE il.UMID = @UMID
	END
	ELSE IF (@ChannelUid IS NOT NULL AND @ConnMessageId IS NOT NULL)
	BEGIN		
		SELECT 
			il.UMID, 
			il.MSISDN, 
			il.ChannelUserId, 
			il.ClientMessageId, 
			il.ClientBatchId, 
			cb.CallbackUrl, 
			il.SubAccountUid,
			il.ChannelId,
			ct.ContentType
		FROM sms.IpmLog il WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON il.UMID = cb.UMID
			INNER JOIN sms.DimContentType ct on ct.ContentTypeId = il.ContentTypeId
		WHERE (
				(@ChannelId IS NOT NULL AND ChannelId IS NOT NULL AND ChannelId = @ChannelId) -- (ChannelId = @ChannelId) will be permanent condition
				OR (ChannelUid = @ChannelUid) -- temporal condition untill channellId will not be fully deployed
			) 
			AND ConnMessageId = @ConnMessageId
	END
END
