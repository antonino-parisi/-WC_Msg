-- =============================================
-- Author: Rebecca Loh
-- Create date: 11 Jun 2020
-- Description: Insert record into cp.AccountSSOConfig
-- Usage : EXEC cp.AccountSSOConfig_Create @AccountUid = '95272080-6282-E711-8143-02D85F55FCE7' ...
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE PROCEDURE [cp].[AccountSSOConfig_Create]
	@AccountUid uniqueidentifier,
	@SSO_Url varchar(1000),
	@Issuer varchar(500),
	@Certificate nvarchar(4000),
	@Metadata varchar(1000) = NULL,
	@Enabled bit = 1
WITH EXECUTE AS OWNER
AS
BEGIN
	OPEN SYMMETRIC KEY AccountCertificate_Key 
	   DECRYPTION BY CERTIFICATE AccountCertificate;

	INSERT INTO cp.AccountSSOConfig
		(AccountUid, SSO_Url, Issuer, [Certificate], Metadata, [Enabled])
	VALUES
		(@AccountUid, EncryptByKey(Key_GUID('AccountCertificate_Key'), @SSO_Url), EncryptByKey(Key_GUID('AccountCertificate_Key'), @Issuer),
		EncryptByKey(Key_GUID('AccountCertificate_Key'), @Certificate), @Metadata, @Enabled) ;

	CLOSE SYMMETRIC KEY AccountCertificate_Key ;
END
