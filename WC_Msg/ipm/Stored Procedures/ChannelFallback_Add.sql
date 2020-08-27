
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-12
-- Description:	Add IPM fallback configuration
-- =============================================
CREATE PROCEDURE [ipm].[ChannelFallback_Add]	
	@SubAccountUid int,
	@Priority int,
	@SuccessStatus int,
	@FallbackDelaySec int,
	@IsTrial bit,
	@ChannelId uniqueidentifier,
	@SkipFallback bit = 0
AS
BEGIN
	
	IF(ipm.Channel_BelongsToSubAccountOrIsSandbox(@SubAccountUid, @IsTrial, @ChannelId) = 1)
	BEGIN
		EXEC ms.SubAccount_SetupBasics_ChatApps @SubAccountUid

		INSERT INTO ipm.ChannelFallback 
			(SubAccountUid, SkipFallback, [Priority], FallbackDelaySec, SuccessStatus, IsForRent, IsTrial, ChannelId)
		VALUES 
			(@SubAccountUid, @SkipFallback, @Priority, @FallbackDelaySec, @SuccessStatus, 0 , @IsTrial, @ChannelId)
	END
	
END
