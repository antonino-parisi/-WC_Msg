-- =============================================
-- Author: Rebecca Loh
-- Create date: 11 Jun 2020
-- Description: Return records from cp.AccountSSOConfig
-- Usage : EXEC cp.AccountSSOConfig_Get
--         EXEC cp.AccountSSOConfig_Get @AccountUid = '95272080-6282-E711-8143-02D85F55FCE7'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [cp].[AccountSSOConfig_Get]
	@AccountUid uniqueidentifier
WITH EXECUTE AS OWNER
AS
BEGIN
	OPEN SYMMETRIC KEY AccountCertificate_Key 
	   DECRYPTION BY CERTIFICATE AccountCertificate;
	SELECT
		AccountUid,
		CONVERT(VARCHAR(1000), DECRYPTBYKEY(SSO_Url)) AS SSO_Url,
		CONVERT(VARCHAR(500), DECRYPTBYKEY(Issuer)) AS Issuer,
		CONVERT(NVARCHAR(MAX), DECRYPTBYKEY([Certificate])) AS [Certificate],
		Metadata,
		[Enabled],
		CreatedAt,
		UpdatedAt
	FROM cp.AccountSSOConfig
	WHERE
		AccountUid = @AccountUid;
	CLOSE SYMMETRIC KEY AccountCertificate_Key ;
END
