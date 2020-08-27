-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-12
-- Description:	Get IPM out fallback configuration for SubAccount
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_Get]	
	@SubAccountUid INT
AS
BEGIN
	
	-- DECLARE @SubAccountUid INT = 18378

	-- Procedure is used in configuration API, it should return all fallbacks 
	-- disregarding on channel status

	SELECT 
		fb.FallbackId,
		fb.SubAccountUid,
		fb.SkipFallback,
		ch.ChannelId,
		ct.ChannelTypeName AS ChannelType,
		fb.[Priority],
		fb.FallbackDelaySec,
		fb.SuccessStatus,
		fb.IsForRent,
		fb.IsTrial
	FROM ipm.ChannelFallback fb
		LEFT JOIN ipm.Channel ch ON fb.ChannelId = ch.ChannelId
		LEFT JOIN ipm.ChannelType ct ON ch.ChannelType = ct.ChannelType
	WHERE SubAccountUid = @SubAccountUid
	ORDER BY [Priority] DESC

END
