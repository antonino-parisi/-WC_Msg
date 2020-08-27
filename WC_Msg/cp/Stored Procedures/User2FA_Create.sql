-- =============================================
-- Author:		Rebecca
-- Create date: 2019-11-20
-- Usage : cp.User2FA_Create @UserId='5BD5B7B2-35F9-4BDB-8B4C-0127945EC3EA', @MSISDN=65333999922
-- =============================================
CREATE PROCEDURE [cp].[User2FA_Create]
	@UserId uniqueidentifier,
	@MSISDN bigint = NULL,
	@TOTP_Encoding varchar(30) = 'Base32',
	@TOTP_Secret varchar(300) = NULL,
	@Preferred char(1) = NULL,	-- 'A' for APP or 'S' for SMS
	@RememberUntil datetime2 = NULL
AS
BEGIN

	IF @Preferred IS NULL
	BEGIN
		SELECT 1 FROM cp.User2FA WITH (NOLOCK)
		WHERE UserId = @UserId ;

		IF @@ROWCOUNT = 0 -- this is the 1st record for client
			SET @Preferred = IIF(@TOTP_Secret IS NOT NULL, 'A', 'S') ;
	END ;

	INSERT INTO cp.User2FA (UserId, MSISDN, TOTP_Encoding, TOTP_Secret, Preferred, RememberUntil)
	VALUES (@UserId, @MSISDN, @TOTP_Encoding, @TOTP_Secret, @Preferred, @RememberUntil) ;
END
