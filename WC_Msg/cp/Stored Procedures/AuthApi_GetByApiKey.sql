
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-10
-- Description:	Auth Api Key - Used in CP as validation before generating a new key
-- =============================================
-- EXEC cp.AuthApi_GetByApiKey @ApiKey='LsAV4XyeXSmlS1N_zuIGqdxzB2VQmbb-KGjIfsW5bOk'
CREATE PROCEDURE [cp].[AuthApi_GetByApiKey]
	@ApiKey varchar(100)
AS
BEGIN
	
	SELECT 
		a.ApiKey, 
		a.Name, 
		a.Active, 
		a.CreatedAt AS CreatedTime, 
		a.LastUsedAt AS LastUsedTime
	FROM ms.AuthApi a
	WHERE a.ApiKey = @ApiKey
		AND a.DeletedAt IS NULL

END

