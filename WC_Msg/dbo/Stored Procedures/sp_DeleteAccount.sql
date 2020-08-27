-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	This stored procedure should be called to delete account properly ( not used )
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteAccount]	
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DELETE  FROM Users WHERE [AccountID]=@AccountId
DELETE  FROM  PlanRouting WHERE [AccountID]= @AccountId
DELETE  FROM  Account WHERE [AccountID]= @AccountId
DELETE  FROM  AccountCredentials WHERE [AccountID]=@AccountId
DELETE FROM PlanRouting WHERE [AccountId]=@AccountId
DELETE FROM AccountBalanceAlert WHERE [AccountId]=@AccountId

END
