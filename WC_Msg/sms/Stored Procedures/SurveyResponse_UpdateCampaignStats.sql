-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-01-28
-- Description:	SurveyResponse - Update CP campaign stats
-- =============================================
CREATE PROCEDURE [sms].[SurveyResponse_UpdateCampaignStats]
	@UMID uniqueidentifier, 
	@FillTimeInSec int
AS
BEGIN
	
	DECLARE @CampaignId int = NULL
	
	-- find Campaign of Message	
	SELECT @CampaignId = b.CampaignId
	FROM sms.SmsLog sl (NOLOCK)
		INNER JOIN cp.CmCampaignBatchIds b ON b.BatchId = sl.BatchId
	WHERE sl.UMID = @UMID

	-- update campaign respond stats
	IF @CampaignId IS NOT NULL
	BEGIN
		UPDATE sms.SurveyResponse
		SET CampaignId = @CampaignId
		WHERE UMID = @UMID

		UPDATE cp.CmCampaign 
		SET MsgResponded = ISNULL(MsgResponded, 0) + 1, 
			AvgRespondTimeInSec = (ISNULL(AvgRespondTimeInSec * MsgResponded, 0) + ISNULL(@FillTimeInSec, 0)) / (ISNULL(MsgResponded, 0) + 1),
			CampaignType = 'survey'
		WHERE CampaignId = @CampaignId
	END
END
