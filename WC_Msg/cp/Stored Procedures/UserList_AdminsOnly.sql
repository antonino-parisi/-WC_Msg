-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-11-26
-- =============================================
-- EXEC cp.UserList_AdminsOnly @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'
-- SELECT TOP 100 * FROM cp.Account 
CREATE PROCEDURE [cp].[UserList_AdminsOnly]
	@AccountUid uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON

	SELECT 
		u.UserId,
		u.Login,
		u.Firstname,
		u.Lastname,
		u.UserStatus, 
		u.AccessLevel
	FROM cp.[User] u
		INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
	WHERE 
		u.AccountUid = @AccountUid 
		AND u.UserStatus IN ('A')	-- active
		AND u.DeletedAt IS NULL
		AND u.AccessLevel = 'A'		-- admins

END
