-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	This function is called by trigger if account or planrouting table are modified
-- it updated the custerconfig table. for all row of Clusterconfig (one row = the configuration for one server)
-- it sets the configurationChanged boolean to 1, so when the server read its configuration ( every minute)
-- it reload the account & PlanRouting table.

-- =============================================
CREATE PROCEDURE [dbo].[sp_configurationChanged]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update ClusterConfig set configurationChanged=1;

END
