-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sumSpentFromAccountBetween]
	-- Add the parameters for the stored procedure here
	@AccountId NVARCHAR(50),
	@begin	date,
	@end	date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SUM(Price) from MessageStats where ( date BETWEEN @begin and @end) AND (AccountId= @AccountId ) 
END
