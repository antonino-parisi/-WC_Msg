
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.User_GetAllForRouting
CREATE PROCEDURE map.User_GetAllForRouting
AS
BEGIN

	SELECT u.UserId, u.Email, u.Firstname, u.LastName
	FROM map.[User] u
	WHERE u.UserStatusId = 1
END

