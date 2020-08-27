-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_NumberOfMessageByHour] 
	-- Add the parameters for the stored procedure here
	@SubAccountId NVARCHAR(MAX),
	@date datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	Select count (*) from [dbo].[TrafficRecord] where DateTimeStamp>@date and Datetimestamp<DATEADD(hour, 1, @date) and SubAccountId=@SubAccountId;
END
