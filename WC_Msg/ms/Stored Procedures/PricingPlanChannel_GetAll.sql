---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Load all blacklisted ipm.PricingPlanChannel
-- =============================================
CREATE PROCEDURE [ms].[PricingPlanChannel_GetAll]
AS
BEGIN
	SELECT 
		ch.ChannelTypeName AS ChannelType,
		p.AccountId,
		p.SubAccountUid,
		p.Country,
		p.Direction AS OutboundMessage,
		ct.ContentType,
		p.Priority,
		p.CostEUR,
		p.CostContract,
		p.ContractCurrency
	FROM ipm.PricingPlanChannel p
		INNER JOIN ipm.ChannelType ch ON p.ChannelTypeId = ch.ChannelTypeId
		LEFT JOIN sms.DimContentType ct ON p.ContentTypeId = ct.ContentTypeId
END
