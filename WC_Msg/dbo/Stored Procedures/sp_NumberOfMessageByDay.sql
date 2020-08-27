-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_NumberOfMessageByDay]
	-- Add the parameters for the stored procedure here
@AccountID NVARCHAR(50),
@date date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@AccountId='')
	BEGIN
	Select SUM(TotalMessage) from MessageStats WHERE  @date=date ;
	END
	ELSE
	BEGIN
	Select SUM(TotalMessage) from MessageStats WHERE @AccountID=AccountID AND @date=date ;
	END
END
