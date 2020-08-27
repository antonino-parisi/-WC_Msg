
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-11
-- Possible exceptions to catch:
--   - Email already exists
-- =============================================
-- EXEC cp.UserActivation_Create @Email='abcd@abcd.sg', @Token='lkjasjdflkasdhlq9p848lkjegakjgljj34q98'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 05/12/2018  Rebecca  added cp.UserActivationClientIP table & cp.UserActivation.ClientIP column

CREATE PROCEDURE [cp].[UserActivation_Create]
	@Email nvarchar(255),
	@Token varchar(100),
	@ExpiresAt datetime = NULL,
	@AccountId varchar(50) = NULL,
	@ClientIP varchar(50) = NULL	-- can be NULL, if coming from 3rd party signup integration
AS
BEGIN

	SET @Email = LTRIM(RTRIM(@Email)) ;

	IF EXISTS (SELECT 1 FROM cp.[User] WHERE Login = @Email AND UserStatus IN ('A', 'I', 'B'))
	BEGIN
		DECLARE @msg NVARCHAR(2048)
		SET @msg = 'Email ' + @Email + 'already registered';
		THROW 51000, @msg, 1;
	END

	-- Check if attempts has reached 5
	
    IF EXISTS (SELECT 1 FROM cp.UserActivation WHERE Email = @Email AND Attempt >= 5)
    BEGIN
        THROW 51001, 'Activation attempts for email reached limit', 1; 
    END

 --   --check IP address counter
    IF EXISTS (
		SELECT 1 FROM cp.UserActivationClientIP
		WHERE 
			ClientIP = @ClientIP
			AND AttemptDate = CAST(GETUTCDATE() AS date) 
			AND Attempt >= 10
	) 
	BEGIN
        THROW 51002, 'IP limit reached', 1; 
    END

	--Set default for @ExpiresAt if NULL
	SET @ExpiresAt = ISNULL(@ExpiresAt, DATEADD(DAY, 2 /* DEFAULT */, GETUTCDATE()))

	-- Insert record
	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS (SELECT 1 FROM cp.UserActivation WHERE Email = @Email)
			INSERT INTO cp.UserActivation (
				Email, Token, Activated, AccountId, CreatedAt, UpdatedAt, ExpiresAt, Attempt, ClientIP)
			VALUES (
				@Email, @Token, 0, @AccountId, SYSUTCDATETIME(), SYSUTCDATETIME(), @ExpiresAt, 1, @ClientIP)
		ELSE
			UPDATE cp.UserActivation
			SET Token = @Token,
				Activated = 0,
				UpdatedAt = SYSUTCDATETIME(),
				ExpiresAt = @ExpiresAt,
				Attempt += 1,
				ClientIP = ISNULL(@ClientIP, ClientIP)
			WHERE Email = @Email

		COMMIT TRANSACTION

		IF @ClientIP IS NOT NULL
		BEGIN
			UPDATE cp.UserActivationClientIP
			SET Attempt += 1
			WHERE ClientIP = @ClientIP
				AND AttemptDate = CAST(GETUTCDATE() AS date) ;
			
			IF @@ROWCOUNT = 0
				INSERT cp.UserActivationClientIP (AttemptDate, ClientIP, Attempt) VALUES (GETUTCDATE(), @ClientIP, 1)
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
