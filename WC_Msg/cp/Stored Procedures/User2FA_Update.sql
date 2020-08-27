-- =============================================
-- Author:		Rebecca
-- Create date: 2019-11-20
-- Usage : cp.User2FA_Update @UserId='5BD5B7B2-35F9-4BDB-8B4C-0127945EC3EA', @MSISDN=6594598282
-- =============================================

CREATE PROCEDURE [cp].[User2FA_Update]
	@UserId uniqueidentifier,
	@MSISDN bigint = NULL,
	@TOTP_Encoding varchar(30) = NULL,
	@TOTP_Secret varchar(300) = NULL,
	@Preferred char(1) = NULL,	-- 'A' for APP or 'S' for SMS
	@RememberUntil datetime2
AS
BEGIN

	UPDATE cp.User2FA
	SET	MSISDN = ISNULL(@MSISDN, MSISDN),
		TOTP_Encoding = ISNULL(@TOTP_Encoding, TOTP_Encoding),
		TOTP_Secret = ISNULL(@TOTP_Secret, TOTP_Secret),
		Preferred = ISNULL(@Preferred, Preferred),
		RememberUntil = ISNULL(@RememberUntil, RememberUntil),
		UpdatedAt = SYSUTCDATETIME()
	WHERE UserId = @UserId ;

END
