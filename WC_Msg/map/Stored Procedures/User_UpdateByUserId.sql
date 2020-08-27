
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- =============================================
-- EXEC map.User_UpdateByUserId @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468', ....
CREATE PROCEDURE [map].[User_UpdateByUserId]
	@UserId smallint,
	@FirstName nvarchar(255),
	@LastName nvarchar(255),
	@TimeZoneId smallint
AS
BEGIN

	UPDATE map.[User]
	SET FirstName = @FirstName, LastName = @LastName, TimeZoneId = @TimeZoneId, UpdatedAt = GETUTCDATE()
	WHERE UserId = @UserId

END

