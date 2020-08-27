-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-28
-- =============================================
-- EXEC cp.UserOnboarding_GetByUserId @UserId = '3e7c675b-61c1-4754-9d34-75350a602335'
CREATE PROCEDURE [cp].[UserOnboarding_GetByUserId]
	@UserId uniqueidentifier,
	@Scenario varchar(10) = NULL -- optional
AS
BEGIN

	SET NOCOUNT ON

	SELECT UserId, Scenario, Passed, LastStep
	FROM cp.UserOnboarding
	WHERE UserId = @UserId
		AND (Scenario = ISNULL(@Scenario, Scenario))
END
