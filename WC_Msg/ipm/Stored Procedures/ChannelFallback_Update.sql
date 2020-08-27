-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-12
-- Description:	Update IPM fallback configuration
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_Update]
	@FallbackId int,
	@SubAccountUid int,
	@Priority int,
	@SuccessStatus int,
	@FallbackDelaySec int,
	@IsTrial bit,
	@ChannelId uniqueidentifier,
	@SkipFallback bit = 0
AS
BEGIN
		
	IF (ipm.Channel_BelongsToSubAccountOrIsSandbox(@SubAccountUid, @IsTrial, @ChannelId) = 1)
		UPDATE ipm.ChannelFallback SET 
			SkipFallback = @SkipFallback,
			[Priority] = @Priority,
			FallbackDelaySec = @FallbackDelaySec,
			SuccessStatus = @SuccessStatus,
			IsTrial = @IsTrial,
			ChannelId = @ChannelId
		WHERE FallbackId = @FallbackId AND SubAccountUid = @SubAccountUid

END
