
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-19
-- =============================================
-- EXEC cp.UserSetupGuide_GetByUserId @UserId = '79B91B38-75AE-4A40-93D9-1D1C56369F99'
CREATE PROCEDURE [cp].[UserSetupGuide_GetByUserId]
	@UserId uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON

	SELECT StepId, Passed
	FROM cp.UserSetupGuide
	WHERE UserId = @UserId
END

