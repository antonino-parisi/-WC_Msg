-- =============================================
-- Author:		RAUL TORREFIEL
-- Create date: 2020-01-16
-- Description:	Get IPM out fallback configuration for SubAccount
-- Based from ipm.ChannelFallback_Get
-- =============================================
-- EXEC [cp].[ChannelFallback_Get] @AccountUid = 'xxx', @SubAccountUid = NULL
CREATE PROCEDURE [cp].[ChannelFallback_Get]
	@AccountUid UNIQUEIDENTIFIER = NULL,	-- it must be mandatory since next release
	@SubAccountUid INT = NULL
AS
BEGIN
	
	IF @AccountUid IS NULL AND @SubAccountUid IS NULL RETURN

	-- remove after next release
	IF @AccountUid IS NULL
		SELECT @AccountUid = AccountUid FROM ms.SubAccount WHERE SubAccountUid = @SubAccountUid
	
	-- main query
	SELECT 
		cf.FallbackId,
        cf.SubAccountUid,
		sa.SubAccountId,
		c.ChannelType AS ChannelType,
        ct.ChannelTypeName,
	    cs.Status AS ChannelStatus,
		cf.Priority,
		cf.FallbackDelaySec,
		cf.SuccessStatus,
	    cf.IsTrial AS IsSandbox
	FROM ipm.ChannelFallback cf
        INNER JOIN ms.SubAccount sa ON cf.SubAccountUid = sa.SubAccountUid
		INNER JOIN ipm.Channel c ON cf.ChannelId = c.ChannelId AND c.Deleted = 0
	    INNER JOIN ipm.ChannelStatus cs ON c.StatusId = cs.StatusId
		LEFT JOIN ipm.ChannelType ct ON c.ChannelType = ct.ChannelType
	WHERE sa.AccountUid = @AccountUid -- don't replace with ipm.Channel.AccountUid cause it will break shared channels for Trial mode
		AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND cf.SubAccountUid = @SubAccountUid))
    ORDER BY cf.SubAccountUid, cf.Priority DESC
END

