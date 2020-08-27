
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2019-11-08
-- =============================================
-- EXEC map.AccountManager_GetAll
CREATE PROCEDURE [map].[AccountManager_GetAll]
AS
BEGIN

	SELECT 
		am.ManagerId, 
		u.Email, 
		u.FirstName, 
		u.LastName, 
		am.Country,
		am.BU
	FROM ms.AccountManager am
		INNER JOIN map.[User] u ON am.ManagerId = u.UserId
	WHERE u.UserStatusId = 1

END
