-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-12-03
-- Description:	Create SubAccount
-- =============================================
-- EXEC map.SubAccount_Create @AccountUid='90904CEC-762D-E811-8147-02D85F55FCE7', @SubAccountId='Advocado_test', @Description='Testing'

CREATE PROCEDURE [map].[SubAccount_Create]
	@AccountUid uniqueidentifier,
	@SubAccountId varchar(50),
	@Description varchar(1000)
AS
BEGIN
	DECLARE @msg varchar(500) ;
	DECLARE @SubAccountUid int ;

	-- verification stage
	IF NOT EXISTS (SELECT 1 FROM cp.Account WHERE AccountUid = @AccountUid)
		BEGIN
			SET @msg = 'No such AccountUid = ' + CAST(@AccountUid AS varchar(50)) ;
			THROW 51000, @msg, 1;
		END ;

	IF EXISTS (SELECT 1 FROM ms.SubAccount WHERE SubAccountId = @SubAccountId)
		BEGIN
			SET @msg = 'SubAccountId = ' + @SubAccountId + ' already exists !' ;
			THROW 51001, @msg, 1;
		END ;

	-- creation stage
	BEGIN TRANSACTION
		BEGIN TRY

		EXEC @SubAccountUid = ms.SubAccount_Create_Internal @AccountUid = @AccountUid, @SubAccountId = @SubAccountId

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION ;
			SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;  
			THROW ;
		END CATCH ;
	
	COMMIT TRANSACTION ;

    SELECT @SubAccountUid AS SubAccountUid, @SubAccountId as SubAccountId;
END
