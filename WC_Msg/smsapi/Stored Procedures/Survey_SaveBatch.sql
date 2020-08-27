-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-04-13
-- Description:	Save survey batch
-- =============================================
CREATE PROCEDURE [smsapi].[Survey_SaveBatch]
	@BatchId uniqueidentifier,
	@SurveyUid int,
	@MessagesCount int,
	@AcceptedCount int,
	@RejectedCount int
AS
BEGIN	
	INSERT INTO sms.SurveyBatch (BatchId, SurveyUid, CreatedAt, MessagesCount, AcceptedCount, RejectedCount)
	VALUES (@BatchId, @SurveyUid, SYSUTCDATETIME(), @MessagesCount, @AcceptedCount, @RejectedCount)
END
