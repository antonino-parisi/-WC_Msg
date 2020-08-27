-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-05-06
-- Description:	Get IPM record status for channel
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 22/07/2020  Igor     Added ChannelID parameter
CREATE PROCEDURE [sms].[IpmLog_GetStatus]
    @Umid uniqueidentifier,
	@ChannelId uniqueidentifier = NULL, -- TODO: will be replaced to mandatory field, after full MessageSphere deployment
    @ChannelUid tinyint
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT StatusId
	FROM sms.IpmLog WITH (NOLOCK)
	WHERE Umid = @Umid AND (
			(@ChannelId IS NOT NULL AND ChannelId IS NOT NULL AND ChannelId = @ChannelId) -- (ChannelId = @ChannelId) will be permanent condition
			OR (ChannelUid = @ChannelUid) -- temporal condition untill channellId will not be fully deployed
		)

END
