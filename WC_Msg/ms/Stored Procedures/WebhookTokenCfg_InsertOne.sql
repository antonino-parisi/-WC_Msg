
CREATE PROCEDURE ms.WebhookTokenCfg_InsertOne
	@AccountUid uniqueidentifier,
	@SubAccountUid int,
	@ResourceType VARCHAR(20),
	@AuthUrl VARCHAR(255),
	@GrantType VARCHAR(20),
	@ClientId VARCHAR(100),
	@ClientSecret VARCHAR(100),
	@TokenFactoryType VARCHAR(20),
	@TokenValiditySec INT
AS
	DECLARE @ClientIdEncrypted VARBINARY(300);
	DECLARE @ClientSecretEncrypted VARBINARY(300);

	OPEN SYMMETRIC KEY WebhookTokenCfg_Key  
		DECRYPTION BY CERTIFICATE WebhookTokenCfg;
		SET @ClientIdEncrypted = EncryptByKey(Key_GUID('WebhookTokenCfg_Key'), @ClientId);
		SET @ClientSecretEncrypted = EncryptByKey(Key_GUID('WebhookTokenCfg_Key'), @ClientSecret);
	CLOSE SYMMETRIC KEY WebhookTokenCfg_Key;

	INSERT INTO ms.WebhookTokenCfg (AccountUid, SubAccountUid, ResourceType, AuthUrl, GrantType, ClientId, ClientSecret, TokenFactoryType, TokenValiditySec)
	VALUES (@AccountUid, @SubAccountUid, @ResourceType, @AuthUrl, @GrantType, @ClientIdEncrypted, @ClientSecretEncrypted, @TokenFactoryType, @TokenValiditySec);
