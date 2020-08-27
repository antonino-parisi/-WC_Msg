
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-10
-- Description:	Auth Api Key - Insert one Key
-- =============================================
-- EXEC cp.AuthApi_Insert @AccountId='AcmeCorp-0aA4C'
CREATE PROCEDURE [cp].[AuthApi_Insert]
	@AccountId varchar(50),
	@Name nvarchar(100) = NULL,
	@ApiKey varchar(100) = NULL
AS
BEGIN
	
	IF (@ApiKey IS NULL) SET @ApiKey = NEWID()
	IF (@Name IS NULL) SET @Name = 'Created on ' + CONVERT(varchar(10), GETUTCDATE(), 20)

	INSERT INTO ms.AuthApi (AccountId, ApiKey, Name, Active)
	VALUES (@AccountId, @ApiKey, @Name, 1)

	EXEC cp.AuthApi_GetByApiKey @ApiKey = @ApiKey
END

