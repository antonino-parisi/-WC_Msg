-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description: Activate an account by activate the account ( deleting the validationTag), the users of the account
-- used by the customer portal on the validate page
-- =============================================
CREATE PROCEDURE [dbo].[sp_ActivateAccountFromUser]
	-- Add the parameters for the stored procedure here
	@Username NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AccountID NVARCHAR(50)
    -- Insert statements for procedure here
	SET @AccountID = (SELECT AccountId FROM Users WHERE Username = @Username)
	UPDATE Users SET Active = 1 WHERE Username = @Username
	UPDATE Account SET Active = 1 WHERE AccountId = @AccountID
	UPDATE AccountCredentials SET ValidationTag = '' WHERE AccountId = @AccountID
	END
