-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
-- EXEC cp.CmCampaign_AddBatchId @CampaignId=1, @BatchId = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D', @SmsTotal = 999, @SmsError = 9
CREATE PROCEDURE [cp].[CmCampaign_AddBatchId]
	@CampaignId int,
	@BatchId uniqueidentifier, -- value, returned from SMS API
	@SmsTotal int,
	@SmsError int
AS
BEGIN
	INSERT INTO cp.CmCampaignBatchIds (CampaignId, BatchId)
	VALUES (@CampaignId, @BatchId)

	UPDATE cp.CmCampaign
	SET SmsTotal += @SmsTotal, 
		SmsError += @SmsError,
		MsgTotal += @SmsTotal,
		MsgError += @SmsError
	WHERE CampaignId = @CampaignId

	-- Survey case - Tempopary compatibility workaround
	DECLARE @TemplateBody nvarchar(1600)
	DECLARE @SubAccountUid int
	DECLARE @CampaignScheduledAt datetime2(2)
		
	SELECT 
		@TemplateBody = TemplateBody, 
		@SubAccountUid = SubAccountUid,
		@CampaignScheduledAt = ISNULL(ScheduledAt, CreatedAt)
	FROM cp.CmCampaign c
	WHERE CampaignId = @CampaignId AND CampaignType = 'survey'

	-- if Campaign is 'survey' type
	IF @TemplateBody IS NOT NULL
	BEGIN
		DECLARE @SurveyUid int
		
		--Extraction of SurveyId from SmsTemplate
		DECLARE @PatternToSearch varchar(50) = 'smstoweb.net?sid='
		--@TemplateBody nvarchar(1600) like this:
		--'klasdlkas http://lazada.smstoweb.net?sid=4199029&lkamsmdas'
		--'klasdlkas http://lazada.smstoweb.net?sid=4199029 bla bla'
		--'http://lazada.smstoweb.net?sid=4199029'
		DECLARE @i int
		SET @i = CHARINDEX(@PatternToSearch, @TemplateBody)
		
		-- if sms contains url to 'smstoweb.net' with sid param
		-- IT MUST BE FIRST PARAM
		IF (@i > 0)
		BEGIN
			SET @TemplateBody = SUBSTRING(@TemplateBody, @i + LEN(@PatternToSearch), LEN(@TemplateBody) - @i - LEN(@PatternToSearch) + 1)
			SET @i = PATINDEX('%[^0-9]%', @TemplateBody)

			SELECT TOP 1 @SurveyUid = SurveyUid
			FROM ms.Survey
			WHERE SubAccountUid = @SubAccountUid
				-- extraction of value of querystring param 'sid' from sms template
				AND [Sid] = SUBSTRING(@TemplateBody, 1, IIF(@i = 0, LEN(@TemplateBody), @i - 1))
		
			-- Compatibility with new analytics
			IF (@SurveyUid IS NOT NULL)
				INSERT INTO sms.SurveyBatch (BatchId, SurveyUid, CreatedAt, MessagesCount, AcceptedCount, RejectedCount) 
				VALUES (@BatchId, @SurveyUid, @CampaignScheduledAt, @SmsTotal, @SmsTotal - @SmsError, @SmsError)
		END
	END
END
