
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-29
-- Description:	Return DLR status to DLR API
-- Obsolite functionality, but still used by Lazada
-- =============================================
-- Examples
--	EXEC [dbo].[sp_SearchTrafficRecord2] @SubAccountId = 'lazada_id_ops1', @UMID = '109bf65b-98e7-e811-814f-022a22cc1c71'
--	EXEC [dbo].[sp_SearchTrafficRecord2] @SubAccountId = 'eatigo_hq', @UMID = '00508454-0899-4afe-b529-d222dc2cb979'
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchTrafficRecord2] 
	@SubAccountId VARCHAR(50),
	@UMID VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
			
	--SELECT TOP (1) tr.Status, tr.UMID, te.WavecellErrorCode as WavecellErrorCode /* Value can be NULL */
	--FROM TrafficRecord tr with(nolock)
	--	LEFT JOIN TrafficErrorCode te WITH (NOLOCK)
	--	ON tr.RouteIdUsed = te.RouteID AND tr.ErrorCode = te.SupplierErrorCode
	--WHERE tr.UMID = @UMID AND tr.SubAccountId = @SubAccountId
	
	SELECT
		dss.StatusOld AS Status,
		CAST(sl.UMID AS VARCHAR(50)) AS UMID,
		te.WavecellErrorCode as WavecellErrorCode /* Value can be NULL */
	FROM sms.SmsLog sl WITH (NOLOCK)
		INNER JOIN sms.DimSmsStatus dss WITH (NOLOCK) ON dss.StatusId = sl.StatusId
		INNER JOIN rt.SupplierConn sc WITH (NOLOCK) ON sc.ConnUid = sl.ConnUid
		LEFT JOIN TrafficErrorCode te WITH (NOLOCK) 
			ON sc.ConnId = te.RouteID AND sl.ConnErrorCode = te.SupplierErrorCode
	WHERE
		(sl.UMID = TRY_CAST(@UMID as uniqueidentifier))

	--IF @@ROWCOUNT = 0
	--BEGIN
	--	SELECT Status, UMID, ErrorCode
	--	FROM TrafficRecordArchive with(nolock)
	--	WHERE @UMID=TrafficRecordArchive.UMID and @SubAccountId=TrafficRecordArchive.SubAccountId
	--END	
END
