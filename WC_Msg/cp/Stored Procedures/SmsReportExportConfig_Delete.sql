
-- =============================================
-- Author: Rebecca Loh
-- Create date: 16 Sep 2019
-- Description: To delete records in cp.SmsReportExportConfig
-- Usage : EXEC cp.SmsReportExportConfig_Delete @UserId='499250FE-E2E5-E611-813F-06B9B96CA965'			
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE PROCEDURE [cp].SmsReportExportConfig_Delete
	@UserId uniqueidentifier
AS
BEGIN
	DELETE FROM cp.SmsReportExportConfig
	WHERE
		CreatedBy = @UserId ;

END
