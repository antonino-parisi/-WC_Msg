-- =============================================
-- Author:		Rebecca
-- Create date: 2019-11-20
-- Usage : EXEC cp.User2FA_Get '1C6832E3-DDD9-4DA3-B4B9-07637D07CBE7'
-- =============================================
CREATE PROCEDURE [cp].[User2FA_Get]
	@UserId uniqueidentifier
AS
BEGIN
	SELECT	UserId,
			MSISDN,
			TOTP_Encoding,
			TOTP_Secret,
			Preferred,
			RememberUntil,
			CreatedAt,
			UpdatedAt
	FROM cp.User2FA
	WHERE UserId = @UserId ;

	-- 2FA feature available for all CP users now, ignoring beta-mode.
	SELECT 1 AS Need2FA
	--FROM cp.User2FA_Toggle
	--WHERE UserId = @UserId ;
END
