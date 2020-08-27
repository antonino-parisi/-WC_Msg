
-- =============================================
-- Author: Rebecca Loh
-- Create date: 13 Sep 2019
-- Description: To get records in cp.SmsReportExportConfig
-- Usage : EXEC cp.SmsReportExportConfig_GetByAccountUserId @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'				
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [cp].[SmsReportExportConfig_GetByAccountUserId]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier
AS
BEGIN
	IF @AccountUid IS NULL AND @UserId IS NULL
		RETURN ;

	SELECT AccountUid, [Columns], Emails, Frequency, PreferredDay, CreatedBy, NextRunAt
	FROM cp.SmsReportExportConfig
	WHERE AccountUid = @AccountUid
		AND CreatedBy = @UserId
END
