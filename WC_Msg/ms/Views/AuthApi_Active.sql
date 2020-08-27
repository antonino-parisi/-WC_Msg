

CREATE VIEW [ms].[AuthApi_Active]
AS
	SELECT 
		ApiKey, 
		AccountId, 
		SubAccountId, 
		Name, 
		Active, 
		CreatedAt AS CreatedTime, 
		LastUsedAt AS LastUsedTime
	FROM  ms.AuthApi
	WHERE Active = 1 AND DeletedAt IS NULL
