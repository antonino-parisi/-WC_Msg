-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-04-18
-- Description:	UrlShorten - Update survey batch stats
-- =============================================
CREATE PROCEDURE [sms].[UrlShorten_UpdateSurveyStats]
	@UMID uniqueidentifier
AS
BEGIN
	
	DECLARE @BatchId uniqueidentifier = NULL
	DECLARE @IntervalInSec int = 0

	-- find Campaign of Message	
	SELECT @BatchId = sl.BatchId, @IntervalInSec = DATEDIFF(SECOND, sl.CreatedTime, SYSUTCDATETIME())
	FROM sms.SmsLog sl (NOLOCK)
	WHERE sl.UMID = @UMID

	-- update survey batch stats
	IF @BatchId IS NOT NULL
		UPDATE sms.SurveyBatch 
		SET MessageClickedCount = ISNULL(MessageClickedCount, 0) + 1, 
			AverageClickTimeInSec = (ISNULL(AverageClickTimeInSec * MessageClickedCount, 0) + @IntervalInSec) / (ISNULL(MessageClickedCount, 0) + 1)
		WHERE BatchId = @BatchId

END
