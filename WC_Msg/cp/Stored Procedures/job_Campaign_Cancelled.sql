-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-10-30
-- =============================================
-- EXEC cp.[job_Campaign_Cancelled]
-- SELECT * FROM cp.CmCampaign
CREATE PROCEDURE [cp].[job_Campaign_Cancelled]
AS
BEGIN
	
	DELETE FROM s
	--SELECT TOP 100 *
	FROM sms.SmsMtScheduled s (NOLOCK)
		INNER JOIN cp.CmCampaignBatchIds cb on s.BatchId = cb.BatchId
		INNER JOIN cp.CmCampaign c ON c.SubAccountUid = s.SubAccountUid AND c.CampaignId = cb.CampaignId
	WHERE c.CampaignStatusId = 5 -- cancelled
		AND c.CreatedAt > DATEADD(HOUR, -1, GETUTCDATE())
END
