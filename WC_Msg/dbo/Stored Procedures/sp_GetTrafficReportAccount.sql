
-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <27-06-2012>
-- Description:	<For checking the is customer need Trafic Report>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetTrafficReportAccount]	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  
	SELECT distinct AccountId FROM Account where IsTrafficReport = 1 AND Active=1
END
