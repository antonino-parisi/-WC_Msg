

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Get Google VSMS agents configuration
-- =============================================
CREATE PROCEDURE [ms].[GoogleVSMS_Agent_GetAll]	
WITH EXECUTE AS OWNER
AS
BEGIN

	OPEN SYMMETRIC KEY GoogleVSMS_Key  
		DECRYPTION BY CERTIFICATE GoogleVSMS;

	SELECT 
		AgentId,
		AgentName,
		GoogleBrandId,
		GoogleAgentId,
		CONVERT(VARCHAR(3000), DecryptByKey(GoogleAgentPrivateKey)) AS GoogleAgentPrivateKey,
		ServiceCredentialClientEmail,
		CONVERT(VARCHAR(3000), DecryptByKey(ServiceCredentialPrivateKey)) AS ServiceCredentialPrivateKey
	FROM ms.GoogleVSMS_Agent
	WHERE Active = 1
	
	CLOSE SYMMETRIC KEY GoogleVSMS_Key;
	
END
