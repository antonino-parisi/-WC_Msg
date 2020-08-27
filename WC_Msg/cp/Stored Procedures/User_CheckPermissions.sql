-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-29
-- =============================================
-- SAMPLE:
-- EXEC cp.User_CheckPermissions @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @UserId = '2A793B40-1E23-47F4-9A95-7662822EE5DB', @SubAccountId = 'PRAKSMOL-4yY8D_hq'
CREATE PROCEDURE [cp].[User_CheckPermissions]
	@AccountUid uniqueidentifier,
	@SubAccountUid int = NULL,
	@SubAccountId varchar(50) = NULL,
	@UserId uniqueidentifier
AS
BEGIN

	IF @SubAccountUid IS NULL
		SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId

	-- access check
	IF NOT EXISTS (
		SELECT 1
		FROM cp.Account a
			INNER JOIN dbo.Account sa ON sa.AccountId = a.AccountId
			INNER JOIN cp.[User] u ON u.AccountUid = a.AccountUid AND u.UserStatus = 'A'
		WHERE a.AccountUid = @AccountUid 
			AND sa.SubAccountUid = @SubAccountUid
			AND u.UserId = @UserId
	)
		THROW 51000, 'Permission error', 1

	-- get flag of filtering by allowed subaccounts for User
    DECLARE @LimitSubAccounts bit = NULL
	SELECT @LimitSubAccounts = cu.LimitSubAccounts 
	FROM cp.[User] cu
	WHERE cu.AccountUid = @AccountUid AND cu.UserId = @UserId AND cu.UserStatus = 'A' AND cu.DeletedAt IS NULL
	
	-- check User permission to access this subaccount
	IF (@LimitSubAccounts IS NULL)
		THROW 51001, 'User is not active ', 1
	ELSE IF (@LimitSubAccounts = 1)
	BEGIN
		IF NOT EXISTS (
			SELECT 1
			FROM cp.UserSubAccount usa
			WHERE usa.UserId = @UserId AND usa.SubAccountUid = @SubAccountUid
		)
			THROW 51002, 'User has no access to subaccount', 1
	END
END
