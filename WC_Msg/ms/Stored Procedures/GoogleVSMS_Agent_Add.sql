

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Add Google VSMS agent
-- =============================================
CREATE PROCEDURE [ms].[GoogleVSMS_Agent_Add]		
	@AgentName VARCHAR(50),
	@GoogleBrandId VARCHAR(50),
	@GoogleAgentId VARCHAR(50),
	@GoogleAgentPrivateKey VARCHAR(3000),
	@ServiceCredentialClientEmail  VARCHAR(100),
	@ServiceCredentialPrivateKey VARCHAR(3000)
--WITH EXECUTE AS OWNER
AS
BEGIN
	
	DECLARE @GoogleAgentPrivateKeyEncrypted VARBINARY(6000);
	DECLARE @ServiceCredentialPrivateKeyEncrypted VARBINARY(6000);
	OPEN SYMMETRIC KEY GoogleVSMS_Key  
		DECRYPTION BY CERTIFICATE GoogleVSMS;
		SET @GoogleAgentPrivateKeyEncrypted = EncryptByKey(Key_GUID('GoogleVSMS_Key'), @GoogleAgentPrivateKey)	
		SET @ServiceCredentialPrivateKeyEncrypted = EncryptByKey(Key_GUID('GoogleVSMS_Key'), @ServiceCredentialPrivateKey)	
	CLOSE SYMMETRIC KEY GoogleVSMS_Key;
	
    INSERT INTO ms.GoogleVSMS_Agent
	   (AgentName, GoogleBrandId, GoogleAgentId, GoogleAgentPrivateKey, ServiceCredentialClientEmail, ServiceCredentialPrivateKey)
	VALUES
	   (@AgentName, @GoogleBrandId, @GoogleAgentId, @GoogleAgentPrivateKeyEncrypted,
		@ServiceCredentialClientEmail, @ServiceCredentialPrivateKeyEncrypted)
	
END
