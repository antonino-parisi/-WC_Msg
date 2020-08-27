
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-28
-- Description:	Delete IPM fallback configuration
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_Delete]
	@FallbackId int
AS
BEGIN	
	DELETE ipm.ChannelFallback WHERE FallbackId = @FallbackId
END
