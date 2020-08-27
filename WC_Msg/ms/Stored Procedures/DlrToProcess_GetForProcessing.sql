-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-17
-- Description:	Load all DLR to resend.
-- =============================================
CREATE PROCEDURE [ms].[DlrToProcess_GetForProcessing]
AS
BEGIN

	UPDATE TOP (3000) sms.DlrToProcess SET InProcess = 1
	OUTPUT inserted.Umid, inserted.StatusId
	WHERE ScheduledAt <= SYSUTCDATETIME() AND InProcess = 0

END
