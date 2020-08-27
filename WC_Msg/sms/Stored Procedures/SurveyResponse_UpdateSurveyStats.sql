-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-04-18
-- Description:	SurveyResponse - Update survey stats
-- =============================================
CREATE PROCEDURE [sms].[SurveyResponse_UpdateSurveyStats]
	@UMID uniqueidentifier,
	--@FillTimeInSec int -- obsolete data: duration of filling survey on page
	@SurveyFinishedAt datetime2(2)	-- time when survey was completed and submitted
AS
BEGIN
	
	DECLARE @BatchId uniqueidentifier = NULL
	DECLARE @SurveyUid int = NULL
	DECLARE @FillTimeInSec int

	SELECT @BatchId = sl.BatchId, @FillTimeInSec = DATEDIFF(SECOND, sl.CreatedTime, @SurveyFinishedAt)
	FROM sms.SmsLog sl (NOLOCK)
	WHERE sl.UMID = @UMID

	-- update survey stats
	IF @BatchId IS NOT NULL
	BEGIN
		SELECT @SurveyUid = SurveyUid
		FROM sms.SurveyBatch
		WHERE BatchId = @BatchId

		IF @SurveyUid IS NOT NULL
		BEGIN
			UPDATE sms.SurveyResponse
			SET SurveyUid = @SurveyUid
			WHERE UMID = @UMID

			UPDATE sms.SurveyBatch
			SET ResponseReceivedCount = ISNULL(ResponseReceivedCount, 0) + 1, 
				AverageResponseReceivedTimeInSec = (ISNULL(AverageResponseReceivedTimeInSec * ResponseReceivedCount, 0) + ISNULL(@FillTimeInSec, 0)) / (ISNULL(ResponseReceivedCount, 0) + 1)
			WHERE BatchId = @BatchId
		END
	END
END
