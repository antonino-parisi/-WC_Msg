-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-01-28
-- Description:	UrlShorten - Update CP campaign stats
-- =============================================
CREATE PROCEDURE [sms].UrlShorten_UpdateCampaignStats
	@UMID uniqueidentifier
AS
BEGIN
	
	DECLARE @CampaignId int = NULL
	DECLARE @IntervalInSec int = 0

	-- find Campaign of Message	
	SELECT @CampaignId = b.CampaignId, @IntervalInSec = DATEDIFF(SECOND, sl.UpdatedTime, SYSUTCDATETIME())
	FROM sms.SmsLog sl (NOLOCK)
		INNER JOIN cp.CmCampaignBatchIds b ON b.BatchId = sl.BatchId
	WHERE sl.UMID = @UMID

	-- update campaign click stats
	IF @CampaignId IS NOT NULL
		UPDATE cp.CmCampaign 
		SET MsgClicked = ISNULL(MsgClicked, 0) + 1, 
			AvgClickTimeInSec = (ISNULL(AvgClickTimeInSec * MsgClicked, 0) + @IntervalInSec) / (ISNULL(MsgClicked, 0) + 1)
		WHERE CampaignId = @CampaignId

END
