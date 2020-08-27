-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-06-28
-- Description:	Load WeChat user matching
-- =============================================
CREATE PROCEDURE [ipm].[WeChatUserMatching_GetAll]
AS
BEGIN
	SELECT SubAccountUid, UserId, Msisdn, ChannelUserId
	FROM ipm.WeChatUserMatching
END
