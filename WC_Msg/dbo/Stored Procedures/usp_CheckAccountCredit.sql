-- =============================================
-- Author:		<Raju>
-- Create date: <17-04-2012>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckAccountCredit]
	@AccountId VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT ValidCredit FROM dbo.AccountCredit WHERE AccountId = @AccountId
           
END

