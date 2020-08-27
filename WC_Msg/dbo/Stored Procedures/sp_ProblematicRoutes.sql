-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.sp_ProblematicRoutes
	-- Add the parameters for the stored procedure here
	@cdate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from MessageStats where date=@cdate and TotalMessage /2  <= ( Error+Pending+Rejected)
END
