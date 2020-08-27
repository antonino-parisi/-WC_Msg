
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-02-28
-- Description:	Check if Channels is Sandbox, or belongs to SubAccount
-- =============================================
CREATE FUNCTION ipm.Channel_BelongsToSubAccountOrIsSandbox
(
	@SubAccountUid int,
	@IsTrial bit,
	@ChannelId uniqueidentifier
)
RETURNS bit
AS
BEGIN

	DECLARE @Result bit = 0;

	-- channel belongs to SubAccount
	IF(EXISTS (SELECT * 
			   FROM ms.SubAccount sa 
			     JOIN ipm.Channel ch ON ch.AccountUid = sa.AccountUid
			   WHERE sa.SubAccountUid = @SubAccountUid AND ch.ChannelId = @ChannelId))
		SET @Result = 1;

    -- Sandbox case: channel is for rent, and registration is trial
	IF(@IsTrial = 1 AND 
		EXISTS (SELECT * FROM ipm.ChannelFallback 
			   WHERE ChannelId = @ChannelId AND IsForRent = 1))
		SET @Result = 1;

	RETURN @Result

END
