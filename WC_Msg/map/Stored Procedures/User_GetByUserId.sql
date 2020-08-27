
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- Description: used during password change process
-- =============================================
-- EXEC map.User_GetByUserId @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468'
CREATE PROCEDURE [map].[User_GetByUserId]
	@UserId smallint,
	@ReturnPasswordHash bit = 0 -- @ReturnPasswordHash=1 used in few cases
AS
BEGIN

	SELECT 
		u.UserId, 
		IIF(@ReturnPasswordHash = 1, u.PasswordHash, NULL) AS PasswordHash, 
		u.Email,
		u.FirstName, 
		u.LastName, 
		u.TimeZoneId
		--, tz.TimeZoneName, tz.Country as TimeZoneCountry
	FROM map.[User] u
		--LEFT JOIN mno.TimeZone tz ON u.TimeZoneId = tz.TimeZoneId
	WHERE UserId = @UserId
		
END
