
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2019-11-08
-- =============================================
-- EXEC map.User_GetAll
CREATE PROCEDURE [map].[User_GetAll]
AS
BEGIN

	SELECT u.UserId, u.Email, u.Firstname, u.LastName
	FROM map.[User] u
	WHERE u.UserStatusId = 1
END
