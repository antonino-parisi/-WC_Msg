
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-01-24
-- Description:	Get survey responses
-- =============================================
-- EXEC cp.CmCampaign_GetSurveyResponses @AccountUid='2318BDEB-C250-E711-8141-06B9B96CA965', @CampaignId = 957
CREATE PROCEDURE [cp].[CmCampaign_GetSurveyResponses]
	@AccountUid uniqueidentifier,
	@CampaignId int,
	@MSISDN bigint = NULL,	-- optional
	@Offset int = 0,
	@Limit int = 200,
	@OutputTotals bit = 0
AS
BEGIN

	IF @Limit > 50000 SET @Limit = 50000

	SELECT sl.UMID, sl.MSISDN, sl.CreatedTime AS SubmittedAt, ss.ShortenStatusName AS DeliveryStatus,
		u.FirstAccessedAt AS FirstClickedAt,
		DATEADD(SECOND, -sr.FillTime, sr.FinishedAt) AS SurveyStartedAt, sr.FinishedAt AS SurveyFinishedAt, 
		sr.ResponseJson, sr.FillTime
	FROM 
		cp.CmCampaign c
		INNER JOIN cp.CmCampaignBatchIds cb ON c.CampaignId = cb.CampaignId
		INNER JOIN sms.SmsLog sl (NOLOCK) ON
			sl.BatchId = cb.BatchId and sl.SubAccountId = c.SubAccountId 
			and sl.CreatedTime BETWEEN DATEADD(MINUTE, -2, c.CreatedAt) AND DATEADD(MINUTE, 20, c.CreatedAt)
		INNER JOIN sms.DimSmsStatus ss ON sl.StatusId = ss.StatusId
		LEFT JOIN sms.UrlShorten u (NOLOCK) on sl.UMID = u.UMID
		LEFT JOIN sms.SurveyResponse sr (NOLOCK) ON sl.UMID = sr.UMID
	WHERE c.CampaignId = @CampaignId
		AND (@MSISDN IS NULL OR (@MSISDN IS NOT NULL AND sl.MSISDN = @MSISDN))
	ORDER BY sl.UMID
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

	IF @OutputTotals = 1
		SELECT SmsTotal - SmsRejected AS TotalMsgAccepted
		FROM cp.CmCampaign
		WHERE CampaignId = @CampaignId
END
