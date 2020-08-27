-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-02
-- Description:	Get scheduled messages for processing
-- =============================================
CREATE PROCEDURE [ms].[ScheduledMessages_GetForProcessing]
AS
BEGIN
	UPDATE TOP (3000) sms.SmsMtScheduled SET InProcess = 1
	OUTPUT inserted.*
	WHERE ScheduledAt <= SYSUTCDATETIME() AND InProcess = 0
END
