-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2020-02-10
-- Description:	Mass activation / deactivation of account 
--       Note: It covers SMS and CA products only. Perhaps Voice later. But VI is out of scope.
-- =============================================
-- EXEC map.Account_UpdateActiveStatus @AccountUid='A4202809-C3CD-E711-8144-02D85F55FCE7', @Active=0
CREATE PROCEDURE [map].[Account_UpdateActiveStatus]
	@AccountUid uniqueidentifier,
	@SubAccountUid int = NULL,
	@UserId uniqueidentifier = NULL,
	@Active bit
AS
BEGIN

	-- CP User activation/deactivation
	IF @UserId IS NOT NULL -- starts with the smallest granularity
	BEGIN

		IF @Active = 0
			EXEC cp.User_Block @AccountUid = @AccountUid, @UserId = @UserId
		ELSE IF @Active = 1
			EXEC cp.User_Unblock @AccountUid = @AccountUid, @UserId = @UserId
			
		RETURN
	END

	-- @UserId is null
	IF @SubAccountUid IS NOT NULL
		BEGIN
			UPDATE ms.SubAccount
			SET [Active] = @Active,
				UpdatedAt = SYSUTCDATETIME()
			WHERE SubAccountUid = @SubAccountUid
				AND AccountUid = @AccountUid
				AND Active <> @Active;

			UPDATE dbo.Account
			SET [Active] = @Active,
				UpdatedAt = SYSUTCDATETIME()
			WHERE SubAccountUid = @SubAccountUid
				AND AccountId = (SELECT AccountId FROM cp.Account WHERE AccountUid = @AccountUid)
				AND Active <> @Active;
		END
	ELSE -- Both @UserId & @SubAccountUid are null
		IF @Active = 1 -- activation of a deactivated account not allowed
			THROW 51000, 'Inverse activation of account is not supported yet', 0 ;
		ELSE -- @Active = 0
			BEGIN
				-- disable SMS and CA subaccounts
				UPDATE ms.SubAccount
				SET Active = 0,
					UpdatedAt = SYSUTCDATETIME()
				WHERE AccountUid = @AccountUid
					AND Active = 1 ;

				UPDATE dbo.Account
				SET Active = 0,
					UpdatedAt = SYSUTCDATETIME()
				WHERE AccountId = (SELECT AccountId FROM cp.Account WHERE AccountUid = @AccountUid)
					AND Active = 1
					AND Deleted = 0 ;

				-- disable CP users
				UPDATE cp.[User]
				SET UserStatus = 'B',
					UpdatedAt = SYSUTCDATETIME()
				WHERE AccountUid = @AccountUid
					AND UserStatus = 'A' ;
			END
END
