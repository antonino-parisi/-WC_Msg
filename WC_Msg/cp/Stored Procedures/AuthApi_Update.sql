
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-10
-- Description:	Auth Api Key - Update one Key
-- =============================================
-- EXEC cp.AuthApi_Update @AccountId='AcmeCorp-0aA4C', @ApiKey='41F7FF86-18CC-E611-813F-020897DF5459', @Name = 'Key 2', @Active = 1
CREATE PROCEDURE [cp].[AuthApi_Update]
	@AccountId varchar(50),
	@ApiKey varchar(100),
	@Name nvarchar(100) = NULL,
	@Active bit
AS
BEGIN
	
	UPDATE ms.AuthApi
	SET Name = COALESCE(@Name, Name), Active = @Active
	WHERE ApiKey = @ApiKey AND AccountId = @AccountId

END

