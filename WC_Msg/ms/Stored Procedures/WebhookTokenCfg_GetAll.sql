
CREATE PROCEDURE ms.WebhookTokenCfg_GetAll
AS
	OPEN SYMMETRIC KEY WebhookTokenCfg_Key  
		DECRYPTION BY CERTIFICATE WebhookTokenCfg;

	SELECT 
		t0.AccountUid,
		t0.SubAccountUid,
		t0.ResourceType,
		t0.AuthUrl,
		t0.GrantType,
		CONVERT(VARCHAR(100), DecryptByKey(t0.ClientId)) AS ClientId,
		CONVERT(VARCHAR(100), DecryptByKey(t0.ClientSecret)) AS ClientSecret,
		t0.TokenFactoryType,
		t0.TokenValiditySec
	FROM ms.WebhookTokenCfg t0;

	CLOSE SYMMETRIC KEY WebhookTokenCfg_Key;
