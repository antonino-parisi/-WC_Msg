-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,24-01-2014,>
-- Description:	<Update balance alert flags>
-- =============================================
Create PROCEDURE [dbo].[usp_UpdateAccountBalanceAlertFlags]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50)
		
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Update AccountBalanceAlert set IsFirstBalanceAlerted=0,IsBalanceZeroAlerted=0,IsFirstOverdraftalerted=0,IsOverdraftZeroalerted=0 where Accountid=@AccountId


   
END









