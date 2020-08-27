-- =============================================
-- Author:		Rebecca
-- Create date: 2019-11-20
-- Usage : cp.User2FA_DELETE @UserId='5BD5B7B2-35F9-4BDB-8B4C-0127945EC3EA'
-- =============================================

CREATE PROCEDURE cp.User2FA_Delete
	@UserId uniqueidentifier
AS
BEGIN

	DELETE cp.User2FA
	WHERE UserId = @UserId ;

END
