-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,17-01-2014,>
-- Description:	<Insert Formula>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertAccountBalanceAlert]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@FirstBalanceAlert Decimal(14,5),
		@FirstOverdraftAlert Decimal(14,5)=null,
		@CreatedBy nvarchar(250),
		@CreatedDateTime datetime
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO AccountBalanceAlert(AccountId,FirstBalanceAlert,FirstOverDraftAlert,CreatedBy,CreatedDateTime,IsFirstBalanceAlerted,IsBalanceZeroAlerted,IsFirstOverdraftalerted,IsOverdraftZeroalerted) 
VALUES(@AccountId,@FirstBalanceAlert,@FirstOverdraftAlert,@CreatedBy,@CreatedDateTime,0,0,0,0)

   
END









