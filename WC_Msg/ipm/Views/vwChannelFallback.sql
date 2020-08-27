CREATE VIEW ipm.vwChannelFallback AS
	SELECT 
		fb.FallbackId, 
		acc.AccountId, 
		sa.SubAccountId, 
		cht.ChannelTypeName, 
		ch.Name, 
		chst.Status, 
		fb.Priority, 
		fb.IsTrial, 
		fb.IsForRent, 
		acc.AccountUid, 
		fb.SubAccountUid
	FROM ipm.ChannelFallback fb
		LEFT JOIN ipm.Channel ch ON fb.ChannelId = ch.ChannelId
		LEFT JOIN ipm.ChannelType cht ON ch.ChannelType = cht.ChannelType
		LEFT JOIN ipm.ChannelStatus chst ON ch.StatusId = chst.StatusId
		LEFT JOIN ms.SubAccount sa ON fb.SubAccountUid = sa.SubAccountUid
		LEFT JOIN cp.Account acc ON sa.AccountUid = acc.AccountUid