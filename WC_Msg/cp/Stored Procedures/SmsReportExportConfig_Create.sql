-- =============================================
-- Author: Rebecca Loh
-- Create date: 13 Sep 2019
-- Description: To create records in cp.SmsReportExportConfig
-- Usage : EXEC cp.SmsReportExportConfig_Create @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'			
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [cp].[SmsReportExportConfig_Create]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@Columns varchar(1000) = NULL,
	@Emails varchar(1000) = NULL,
	@Frequency char(1) = 'M',
	@PreferredDay tinyint = 0,
	@NextRunAt datetime = NULL
AS
BEGIN
	IF @AccountUid IS NULL OR @UserId IS NULL
		RETURN ;

	INSERT INTO cp.SmsReportExportConfig
		(AccountUid, [Columns], Emails, Frequency, PreferredDay, CreatedBy, NextRunAt)
	VALUES
		(@AccountUid, @Columns, @Emails, @Frequency, @PreferredDay, @UserId, @NextRunAt) ;

END
