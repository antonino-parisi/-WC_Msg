
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-04
-- =============================================
-- EXEC cp.CmCampaign_UpdateStatus @AccountUid='5C9250FE-E2E5-E611-813F-06B9B96CA965', @CampaignId = 6, @CampaignStatusId = 2
CREATE PROCEDURE [cp].[CmCampaign_UpdateStatus]
	@AccountUid uniqueidentifier,
	@CampaignId int,
    @CampaignStatusId tinyint,
	@ScheduledAt datetime2(2) = NULL,
	@RejectionMsg varchar(500) = NULL,
    @ReviewedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		-- TODO: CP API should run async task to call cancellation api for each BatchId of campaign
		-- Here is dirty workaround solution to save 3+ days of Web team on calling api
		IF (@CampaignStatusId = 5)
			DELETE FROM s
			FROM sms.SmsMtScheduled s
				INNER JOIN cp.CmCampaignBatchIds cb WITH (NOLOCK) ON s.BatchId = cb.BatchId
				INNER JOIN dbo.Account sa WITH (NOLOCK) ON s.SubAccountUid = sa.SubAccountUid
				INNER JOIN cp.Account a WITH (NOLOCK) ON a.AccountId = sa.AccountId
			WHERE cb.CampaignId = @CampaignId AND a.AccountUid = @AccountUid ;

		UPDATE cp.CmCampaign
		SET CampaignStatusId = @CampaignStatusId,
			ScheduledAt = ISNULL(@ScheduledAt, ScheduledAt),
			RejectionMsg = IIF(@CampaignStatusId=7, @RejectionMsg, RejectionMsg),
            ReviewedAt = IIF(@CampaignStatusId=7 OR @CampaignStatusId=6, GETUTCDATE(), ReviewedAt),
            ReviewedBy = ISNULL(@ReviewedBy, ReviewedBy)
		WHERE CampaignId = @CampaignId AND AccountUid = @AccountUid ;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION ;
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;  
		THROW ;
	END CATCH ;

	COMMIT TRANSACTION ;

	SELECT 
		a.AccountId, c.AccountUid, 
		c.SubAccountId, c.SubAccountUid,
		c.Product,
		c.CampaignId, c.CampaignStatusId, 
        c.CampaignName,
		c.ScheduledAt, 
		c.RejectionMsg,
		c.ReviewedBy, c.ReviewedAt
	FROM cp.CmCampaign c WITH (NOLOCK) 
		INNER JOIN cp.Account a WITH (NOLOCK)
		ON c.AccountUid = a.AccountUid 
	WHERE c.CampaignId = @CampaignId;

END
