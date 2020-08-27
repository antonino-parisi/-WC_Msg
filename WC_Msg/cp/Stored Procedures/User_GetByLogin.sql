-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-10-04
-- Differentiate unregistered and suspended accounts
-- Used to authenticate user or to get data when reset password
-- =============================================
-- EXEC cp.User_GetByLogin @Login = 'atrony+123@gmail.com'
CREATE PROCEDURE [cp].[User_GetByLogin]
	@Login nvarchar(255),
	@Password nvarchar(50) = NULL -- deprecated
AS
BEGIN

	SET NOCOUNT ON

	SELECT 
		u.UserId, 
		a.AccountId, 
		u.PasswordHash, 
		u.SecretKey, 
		u.Firstname, u.Lastname, 
		u.AccountUid, 
		a.IsV2Allowed, 
		u.PasswordResetForce, 
		u.UserStatus,
        u.PasswordExpiresAt,
        u.PasswordHashAlgorithm,
		0 AS v1PasswordMatched --deprecated field
	FROM cp.[User] u
		INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
		LEFT JOIN dbo.Users ou ON ou.Username = u.Login
	WHERE 
		u.Login = @Login 
		AND u.UserStatus IN ('A', 'I', 'B') 
		AND u.DeletedAt IS NULL 

END
