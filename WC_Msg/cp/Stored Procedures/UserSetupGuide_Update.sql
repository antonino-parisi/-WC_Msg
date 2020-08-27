
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-19
-- =============================================
-- EXEC cp.UserSetupGuide_Update @UserId = '3e7c675b-61c1-4754-9d34-75350a602335', @StepId = 1, @Passed = 1
CREATE PROCEDURE [cp].[UserSetupGuide_Update]
	@UserId uniqueidentifier,
	@StepId tinyint,
	@Passed bit
AS
BEGIN

	SET NOCOUNT ON

	IF EXISTS (SELECT 1 FROM cp.UserSetupGuide WHERE UserId = @UserId AND StepId = @StepId)
	BEGIN
		UPDATE cp.UserSetupGuide 
		SET Passed = @Passed
		WHERE UserId = @UserId AND StepId = @StepId
	END
	ELSE
	BEGIN
		INSERT INTO cp.UserSetupGuide (UserId, StepId, Passed)
		VALUES (@UserId, @StepId, @Passed)
	END
END

