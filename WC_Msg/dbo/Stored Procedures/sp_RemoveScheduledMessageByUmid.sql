CREATE PROCEDURE [dbo].[sp_RemoveScheduledMessageByUmid]
	@UMID VARCHAR(50),
	@SubAccountId VARCHAR(50)
AS
BEGIN
	DELETE FROM dbo.ScheduledMessages
	WHERE UMID = @UMID and SubAccountId = @SubAccountId
END