-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-02-26
-- Description:	Unschedule message by BatchId
-- =============================================
CREATE PROCEDURE [ms].[ScheduledMessages_RemoveByBatchId]
	@BatchId uniqueidentifier,
	@SubAccountUid int
AS
BEGIN
	DELETE FROM sms.SmsMtScheduled
	WHERE BatchId = @BatchId AND SubAccountUid = @SubAccountUid
END
