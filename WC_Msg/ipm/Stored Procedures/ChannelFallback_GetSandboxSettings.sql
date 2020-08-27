-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-12-10
-- Description:	Get IPM sandbox settings
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_GetSandboxSettings]	
AS
BEGIN

	SELECT 
		fb.SubAccountUid,
		t.ChannelTypeId AS ChannelUid, -- obsolete, to be removed
		ch.ChannelId,
		t.ChannelTypeName,
		fb.IsTrial,
		fb.IsForRent
	FROM ipm.ChannelFallback fb
		LEFT JOIN ipm.Channel ch ON ch.ChannelId = fb.ChannelId
		LEFT JOIN ipm.ChannelType t ON t.ChannelType = ch.ChannelType
	WHERE ch.ChannelType <> 'SM' AND (fb.IsTrial = 1 OR fb.IsForRent = 1)
	
END
