-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,19-03-2013,>
-- Description:	<Update cost session data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateCostSessionData]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@SubAccountId NVARCHAR(50),
		@Operator NVARCHAR(200),
		@RouteId NVARCHAR(50),
		@Price FLOAT,
		@Cost FLOAT,
		@Margin FLOAT,
		@MarginPercent FLOAT,
		@UpdateMargin FLOAT,
		@UpdateMarginPercent FLOAT,
		@SessionId NVARCHAR(250)
		
		
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [CostSessionData]
    SET [Price] = @Price,     
      [Cost] = @Cost,
      [Margin] = @Margin,
      [MarginPercent] = @MarginPercent,
      [UpdateMargin]=@UpdateMargin,[UpdateMarginpercent]=@UpdateMarginPercent,
      [DateTimeUpdated]=getdate()
 WHERE [AccountId]=@AccountId AND [SubAccountId]=@SubAccountId AND [RouteId]=@RouteId AND [Operator]=@Operator AND SessionId=@SessionId
END







