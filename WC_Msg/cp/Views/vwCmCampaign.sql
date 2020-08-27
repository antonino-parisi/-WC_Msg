


CREATE VIEW [cp].[vwCmCampaign]
AS
	SELECT 
		c.CampaignId
		,c.AccountUid
		,a.AccountId
		,sa.SubAccountId
		,c.SubAccountUid
		,c.ChannelType
		,c.CampaignName
		,c.TemplateBody
		,c.TemplateSenderId
		,c.SmsTotal
		,c.SmsAccepted
		,c.SmsCharged
		,c.SmsDelivered
		,c.SmsRejected
		,c.SmsError
		,c.MsgTotal
		,c.MsgAccepted
		,c.MsgDelivered
		,c.MsgRejected
		,c.MsgError
		,c.MsgClicked
		,c.MsgResponded
		,c.AvgClickTimeInSec
		,c.AvgRespondTimeInSec
		,c.Price
		,c.PriceCurrency
		,c.PriceUSD
		,c.CostUSD
		,c.ScheduledAt
		,c.CompletedAt
		,c.CreatedAt
		,c.CreatedBy
		,c.DeletedAt
		,c.DeletedBy
		,c.CampaignStatusId
		,cs.CampaignStatusName
		,c.TemplateId
	FROM cp.CmCampaign c (NOLOCK)
		LEFT JOIN ms.SubAccount AS sa ON c.SubAccountUid = sa.SubAccountUid
		LEFT JOIN cp.Account a ON a.AccountUid = c.AccountUid
		LEFT JOIN cp.CmCampaignStatus cs ON c.CampaignStatusId = cs.CampaignStatusId
