
-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <27-06-2012>
-- Description:	<For checking the job>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetJobs]	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  
	SELECT * FROM Jobs where Active = 1
END
