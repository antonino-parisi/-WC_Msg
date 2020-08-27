
-- =============================================
-- Author: Rebecca Loh
-- Create date: 13 Sep 2019
-- Description: To update records in cp.SmsReportExportConfig
-- Usage : EXEC cp.SmsReportExportConfig_Update @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'			
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE PROCEDURE [cp].[SmsReportExportConfig_Update]
	@UserId uniqueidentifier,
	@Columns varchar(1000) = NULL,
	@Emails varchar(1000) = NULL,
	@Frequency char(1) = NULL,
	@PreferredDay tinyint = NULL,
	@LastRunAt datetime = NULL,
	@NextRunAt datetime = NULL
AS
BEGIN
	UPDATE cp.SmsReportExportConfig
	SET [Columns] = ISNULL(@Columns, [Columns]),
		Emails = ISNULL(@Emails, Emails),
		Frequency = ISNULL(@Frequency, Frequency),
		PreferredDay = ISNULL(@PreferredDay, PreferredDay),
		LastRunAt = ISNULL(@LastRunAt, LastRunAt),
		NextRunAt = ISNULL(@NextRunAt, NextRunAt)
	WHERE
		CreatedBy = @UserId ;

END
