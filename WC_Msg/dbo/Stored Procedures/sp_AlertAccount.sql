-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Detect the account where the credit is less than the Alert Value ( not used now)
-- =============================================
CREATE PROCEDURE [dbo].[sp_AlertAccount]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT AccountCredit.AccountId from AccountCredit Join AccountCredentials 
										on ( AccountCredit.AccountId = AccountCredentials.AccountId)
	where AccountCredit.CreditEuro < AccountCredentials.AlertValue;
END
