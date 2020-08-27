-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-02
-- Description:	Unschedule message by UMID
-- =============================================
CREATE PROCEDURE [ms].[ScheduledMessages_RemoveByUmid]
	@UMID uniqueidentifier,
	@SubAccountUid int
AS
BEGIN
	DELETE FROM sms.SmsMtScheduled 
	WHERE UMID = @UMID AND SubAccountUid = @SubAccountUid
END
