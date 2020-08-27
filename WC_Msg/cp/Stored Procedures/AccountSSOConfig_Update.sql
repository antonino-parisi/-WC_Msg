-- =============================================
-- Author: Rebecca Loh
-- Create date: 11 Jun 2020
-- Description: Insert record into cp.AccountSSOConfig
-- Usage : EXEC cp.AccountSSOConfig_Update @AccountUid = '95272080-6282-E711-8143-02D85F55FCE7', @Enabled=0
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE PROCEDURE [cp].[AccountSSOConfig_Update]
	@AccountUid uniqueidentifier,
	@SSO_Url varchar(1000) = NULL,
	@Issuer varchar(500) = NULL,
	@Certificate nvarchar(4000) = NULL,
	@Metadata varchar(1000) = NULL,
	@Enabled bit = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	OPEN SYMMETRIC KEY AccountCertificate_Key 
	   DECRYPTION BY CERTIFICATE AccountCertificate;

	IF @SSO_Url IS NOT NULL
		UPDATE cp.AccountSSOConfig
		SET SSO_Url = EncryptByKey(Key_GUID('AccountCertificate_Key'), @SSO_Url),
			UpdatedAt = SYSUTCDATETIME()
		WHERE AccountUid = @AccountUid ;

	IF @Issuer IS NOT NULL
		UPDATE cp.AccountSSOConfig
		SET Issuer = EncryptByKey(Key_GUID('AccountCertificate_Key'), @Issuer),
			UpdatedAt = SYSUTCDATETIME()
		WHERE AccountUid = @AccountUid ;

	IF @Certificate IS NOT NULL
		UPDATE cp.AccountSSOConfig
		SET [Certificate] = EncryptByKey(Key_GUID('AccountCertificate_Key'), @Certificate),
			UpdatedAt = SYSUTCDATETIME()
		WHERE AccountUid = @AccountUid ;

	IF @Metadata IS NOT NULL OR @Enabled IS NOT NULL
		UPDATE cp.AccountSSOConfig
		SET Metadata = ISNULL(@Metadata, [Metadata]),
			[Enabled] = ISNULL(@Enabled, [Enabled]),
			UpdatedAt = SYSUTCDATETIME()
		WHERE AccountUid = @AccountUid ;

	CLOSE SYMMETRIC KEY AccountCertificate_Key ;

END
