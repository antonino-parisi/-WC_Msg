
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-10
-- Description:	Auth Api Key - Update one Key
-- =============================================
-- EXEC cp.AuthApi_Delete @AccountId='AcmeCorp-0aA4C', @ApiKey='41F7FF86-18CC-E611-813F-020897DF5459'
CREATE PROCEDURE [cp].[AuthApi_Delete]
	@AccountId varchar(50),
	@ApiKey varchar(100)
AS
BEGIN
	
	UPDATE ms.AuthApi
	SET DeletedAt = GETUTCDATE()
	WHERE ApiKey = @ApiKey AND AccountId = @AccountId

END

