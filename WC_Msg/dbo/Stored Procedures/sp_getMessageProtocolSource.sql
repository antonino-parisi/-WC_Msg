-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getMessageProtocolSource] 
	-- Add the parameters for the stored procedure here
		@UMID nvarchar(MAX),
	@subAccountId nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP 1  TrafficRecord.ProtocolSource
	from [dbo].[TrafficRecord] WITH(NOLOCK)
	where TrafficRecord.UMID=@UMID and TrafficRecord.SubAccountId=@SubAccountId
END
