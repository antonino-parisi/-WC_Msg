-- =============================================
-- Author:		Sadeep Madurange
-- Create date: 2020-06-11
-- Description:	Procedure for querying message details for Chat Apps
-- =============================================
CREATE PROCEDURE [sms].[IpmLog_GetForApi]
	@Umid UNIQUEIDENTIFIER,
	@SubAccountUid INT
--WITH EXECUTE AS OWNER
AS
	SELECT
		il.UMID AS Umid,
		sa.SubAccountId,
		il.ChannelId,
		il.MSISDN AS Msisdn,	-- PII. Don't forget to MASK value in api
		il.ChannelUserId,
		il.ChannelUid AS ChannelTypeId,
		IIF(il.Direction = 0, 'inbound', 'outbound') As Direction,
		il.Country,
		il.StatusId,
		--dss.Status,
		CASE WHEN il.StatusId = 40 THEN il.DeliveredAt
			 WHEN il.StatusId = 50 THEN il.ReadAt
			 ELSE il.UpdatedAt
		END	AS EventTime,
		il.ConnErrorCode,
		dct.ContentType,
		il.Content,	-- PII. Don't forget to MASK value in api
		il.CreatedAt,
		il.ClientMessageId,
		il.ClientBatchId,
		il.BatchId,
		il.Step
	FROM sms.IpmLog il (NOLOCK)
		INNER JOIN ms.SubAccount sa (NOLOCK) ON sa.SubAccountUid = il.SubAccountUid
		INNER JOIN ipm.ChannelType ct (NOLOCK) ON ct.ChannelTypeId = il.ChannelUid
		INNER JOIN cp.Account a (NOLOCK) ON a.AccountUid = sa.AccountUid
		-- workaround, as it might be few rows with same StatusId sometimes
		-- Igor's comment: for IpmLog we dont' store DRs in sms.DlrLog (look at [sms].[IpmLog_Update])
		-- OUTER APPLY (SELECT TOP 1 EventTime FROM sms.DlrLog WITH (NOLOCK, FORCESEEK) WHERE UMID = il.UMID AND StatusId = il.StatusId ORDER BY DlrLogId) dl
		INNER JOIN sms.DimContentType dct (NOLOCK) ON dct.ContentTypeId = il.ContentTypeId
	WHERE il.UMID = @Umid AND il.SubAccountUid = @SubAccountUid
