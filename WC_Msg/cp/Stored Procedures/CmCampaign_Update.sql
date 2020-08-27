-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
-- EXEC cp.CmCampaign_Update @AccountUid='AcmeCorp-0aA4C', @CampaingId = 123, @CampaignName = 'asd'
CREATE PROCEDURE [cp].[CmCampaign_Update]
	@AccountUid uniqueidentifier,
	@CampaignId int,
    @CampaignName nvarchar(100) = NULL,
	@ScheduledAt datetime2(2) = NULL,
	@ApprovalDeadlineAt smalldatetime = NULL,
	@CampaignDetailsUrl varchar(300) = NULL,
	@ApprovalDeadlineNotified bit = NULL,
	@RejectionMsg varchar(500) = NULL
AS
BEGIN
	UPDATE cp.CmCampaign
	SET CampaignName= ISNULL(@CampaignName, CampaignName),
		ScheduledAt = ISNULL(@ScheduledAt, ScheduledAt),
		ApprovalDeadlineAt = ISNULL(@ApprovalDeadlineAt, ApprovalDeadlineAt),
		CampaignDetailsUrl = ISNULL(@CampaignDetailsUrl, CampaignDetailsUrl),
		ApprovalDeadlineNotified = ISNULL(@ApprovalDeadlineNotified, ApprovalDeadlineNotified),
		RejectionMsg = ISNULL(@RejectionMsg, RejectionMsg)
	WHERE CampaignId = @CampaignId AND AccountUid = @AccountUid ;

	SELECT 
		a.AccountId, c.AccountUid, sa.SubAccountId, c.SubAccountUid, c.Product,
		c.CampaignId, c.CampaignStatusId, c.CampaignName, c.ScheduledAt,
		c.ApprovalDeadlineAt, c.CampaignDetailsUrl, c.ApprovalDeadlineNotified, c.RejectionMsg
	FROM cp.CmCampaign c WITH (NOLOCK) 
		INNER JOIN ms.SubAccount sa WITH (NOLOCK) ON c.SubAccountUid = sa.SubAccountUid
		INNER JOIN cp.Account a WITH (NOLOCK) ON c.AccountUid = a.AccountUid 
	WHERE c.CampaignId = @CampaignId ;
END
