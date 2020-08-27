-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,16-07-2013,>
-- Description:	<Update Formula>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateBalanceAlert]
	-- Add the parameters for the stored procedure here
		@Accountid nvarchar(50),
		@FirstBalanceAlert decimal(14,5),
		@FirstOverDraftAlert decimal(14,5)=null,
		@UpdatedBy NVARCHAR(250),		
		@UpdateDateTime datetime
									
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Cost=ROUND(@_cost,4)
  Update AccountBalanceAlert set 
  FirstBalanceAlert= @FirstBalanceAlert , FirstOverDraftAlert= @FirstOverDraftAlert, UpdatedBy=@UpdatedBy,UpdateDateTime= @UpdateDateTime 
   where AccountId=@Accountid
END







