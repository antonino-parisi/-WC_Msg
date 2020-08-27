-- =============================================
-- Author:		Anton Shchekalov
-- Create date: ??
-- =============================================
CREATE PROCEDURE [cp].[CmCampaign_GetOne]
    @AccountUid UNIQUEIDENTIFIER,
    @CampaignId int
AS
BEGIN

    SELECT 
		cm.CampaignId, cm.CampaignName, 
        cm.CampaignStatusId, st.CampaignStatusName,
        cm.TemplateBody, cm.TemplateSenderId, cm.TemplateId,
        -- cm.CampaignType,
        -- counters
        -- cm.SmsTotal, cm.SmsDelivered, 
        -- cm.SmsError + cm.SmsRejected AS SmsError, 
        -- cm.SmsTotal - cm.SmsDelivered - cm.SmsRejected - cm.SmsError AS SmsUndelivered,
        -- cm.MsgTotal, cm.MsgDelivered, 
        -- cm.MsgError + cm.MsgRejected AS MsgError, 
        -- cm.MsgTotal - cm.MsgDelivered - cm.MsgRejected - cm.MsgError AS MsgUndelivered,
        -- cm.MsgClicked, cm.MsgResponded, 
        -- cm.Price, cm.PriceCurrency,
        cm.CreatedAt, cm.CreatedBy, 
        cm.ScheduledAt,
        cm.ApprovalDeadlineAt,
        cm.CampaignDetailsUrl,
        u.[Login] as CreatedBy_Username,
        --cm.AvgClickTimeInSec, cm.AvgRespondTimeInSec AS AvgSurveyFillTimeInSec,
        --cm.AvgClickTimeInSec + cm.AvgRespondTimeInSec AS AvgSurveyResponseTimeInSec,
		cm.SubAccountUid,
        sa.SubAccountId,
		cm.Product,
		cm.ChannelType,
		cm.ClientMessageId
    FROM cp.CmCampaign cm
        LEFT JOIN cp.CmCampaignStatus st ON cm.CampaignStatusId = st.CampaignStatusId
        LEFT JOIN cp.[User] u ON cm.CreatedBy = u.UserId
        LEFT JOIN ms.SubAccount sa ON sa.SubAccountUid = cm.SubAccountUid
    WHERE CampaignId = @CampaignId AND cm.AccountUid = @AccountUid;

END
