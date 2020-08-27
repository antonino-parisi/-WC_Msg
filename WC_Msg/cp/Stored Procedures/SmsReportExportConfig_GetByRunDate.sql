

-- =============================================
-- Author: Rebecca Loh
-- Create date: 13 Sep 2019
-- Description: To get records in cp.SmsReportExportConfig
-- Usage : EXEC cp.SmsReportExportConfig_GetByRunDate @LastRunDate='2019-09-13'			
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [cp].[SmsReportExportConfig_GetByRunDate]
	@LastRunDate date = NULL,
	@NextRunDate date = NULL
AS
BEGIN
	IF @LastRunDate IS NULL AND @NextRunDate IS NULL
		RETURN ;

	SELECT AccountUid, [Columns], Emails, Frequency, PreferredDay, CreatedBy, NextRunAt 
	FROM cp.SmsReportExportConfig
	WHERE (@LastRunDate IS NOT NULL AND LastRunAt >= @LastRunDate AND LastRunAt < DATEADD(dd, 1, @LastRunDate))
		OR (@NextRunDate IS NOT NULL AND NextRunAt >= @NextRunDate AND NextRunAt < DATEADD(dd, 1, @NextRunDate)) ;
END
