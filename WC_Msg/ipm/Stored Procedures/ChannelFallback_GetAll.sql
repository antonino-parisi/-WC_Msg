

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-12
-- Description:	Get IPM out fallback configuration
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_GetAll]	
AS
BEGIN
	
	SELECT 
		fb.SubAccountUid,
		fb.SkipFallback,
		ct.ChannelTypeName AS ChannelType,
		fb.Priority,
		fb.FallbackDelaySec,
		fb.SuccessStatus,
		fb.ChannelId
	FROM ipm.ChannelFallback fb
		LEFT JOIN ipm.Channel ch ON ch.ChannelId = fb.ChannelId
		LEFT JOIN ipm.ChannelType ct ON ch.ChannelType = ct.ChannelType
	WHERE ch.StatusId = 'A'

END
