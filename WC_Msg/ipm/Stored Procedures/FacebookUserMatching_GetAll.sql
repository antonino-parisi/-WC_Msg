-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-10-12
-- Description:	Load Facebook user matching
-- =============================================
CREATE PROCEDURE [ipm].[FacebookUserMatching_GetAll]
AS
BEGIN
	SELECT SubAccountUid, UserId, PageId, MSISDN, ChannelUserId
	FROM ipm.FacebookUserMatching
END
