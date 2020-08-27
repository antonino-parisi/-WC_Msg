
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- =============================================
-- EXEC map.User_Create @UserId = 'weqwe', @Token = 'awekljljhq', ...
CREATE PROCEDURE [map].[User_Create]
	@Email varchar(255),
	@PasswordHash varbinary(1024), --@PasswordHash with format "algorithm:iterations:salt:hash"
	@FirstName nvarchar(255) = NULL,
	@LastName nvarchar(255) = NULL,
	@TimeZoneName varchar(35) = NULL
AS
BEGIN

	SET NOCOUNT ON

	-- Get timezone id
	DECLARE @TimeZoneid smallint
	--SELECT @TimeZoneid = TimeZoneid FROM mno.TimeZone WHERE TimeZoneName = @TimeZoneName

	-- Insert new User
	BEGIN TRY
		BEGIN TRANSACTION
	
		INSERT INTO map.[User] (Email, PasswordHash, FirstName, LastName, TimeZoneId)
		VALUES (@Email, @PasswordHash, @FirstName, @LastName, @TimeZoneId)

		SELECT SCOPE_IDENTITY() AS UserId

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

END

