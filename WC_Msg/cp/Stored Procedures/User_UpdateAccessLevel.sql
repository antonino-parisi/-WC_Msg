-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-19
-- =============================================
-- EXEC cp.User_UpdateAccessLevel @UserId='...'
CREATE PROCEDURE [cp].[User_UpdateAccessLevel]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@AccessLevel char(1),
	@LimitSubAccounts bit = NULL,	-- skip column update for NULL input
	@LimitRoles bit	= NULL			-- skip column update for NULL input
AS
BEGIN
	UPDATE u 
	SET 
		AccessLevel = @AccessLevel,
		LimitSubAccounts = ISNULL(@LimitSubAccounts, LimitSubAccounts),
		LimitRoles = ISNULL(@LimitRoles, LimitRoles),
		UpdatedAt = SYSUTCDATETIME()
	FROM cp.[User] u
	WHERE 
		u.UserId = @UserId 
		AND u.AccountUid = @AccountUid 
		AND u.UserStatus IN ('A', 'I')
END
