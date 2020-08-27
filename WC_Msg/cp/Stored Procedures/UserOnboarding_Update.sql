
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-28
-- =============================================
-- EXEC cp.UserOnboarding_Update @UserId = '3e7c675b-61c1-4754-9d34-75350a602335', @Scenario = 'SMS_SENDER', @Passed = 1, @LastStep = 1
CREATE PROCEDURE [cp].[UserOnboarding_Update]
	@UserId uniqueidentifier,
	@Scenario varchar(10),
	@Passed bit,
	@LastStep tinyint = NULL
AS
BEGIN

	SET NOCOUNT ON

	IF EXISTS (SELECT 1 FROM cp.UserOnboarding WHERE UserId = @UserId AND Scenario = @Scenario)
	BEGIN
		UPDATE cp.UserOnboarding 
		SET Passed = @Passed, LastStep = ISNULL(@LastStep, LastStep)
		WHERE UserId = @UserId AND Scenario = @Scenario
	END
	ELSE
	BEGIN
		INSERT INTO cp.UserOnboarding (UserId, Scenario, Passed, LastStep)
		VALUES (@UserId, @Scenario, @Passed, @LastStep)
	END
END
