
-- =============================================
-- Author:		Anton
-- Create date: 2020-06-16
-- Usage : 
--	EXEC cp.CpCampaignSummary_Get @SubAccountUid = 6716, @CampaignId=34385
-- ============================================
CREATE PROCEDURE [cp].[CmCampaignSummary_Get]
	@SubAccountUid int,
	@CampaignId int
AS
BEGIN

	SELECT
		ccs.CampaignId,
		ct.ChannelType, 
		ccs.MsgTotal, 
		ccs.MsgDelivered,	-- note MsgDelivered includes MsgRead
		ccs.MsgRead, 
		ccs.MsgAccepted - ccs.MsgDelivered AS MsgUndelivered, 
		ccs.MsgRejected,
		ccs.MsgCharged,
		ccs.PriceCurrency AS Currency, 
		ccs.Price
	FROM cp.CmCampaignSummary AS ccs
		INNER JOIN cp.CmCampaign AS cc ON ccs.CampaignId = cc.CampaignId
		INNER JOIN ipm.ChannelType AS ct ON ccs.ChannelTypeId = ct.ChannelTypeId
	WHERE ccs.CampaignId = @CampaignId AND cc.SubAccountUid = @SubAccountUid
	ORDER BY cc.MsgTotal DESC

END
