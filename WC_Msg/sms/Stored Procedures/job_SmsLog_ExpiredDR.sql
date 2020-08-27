-- =============================================
-- Author: Anton Shchekalov
-- Description:	Job to generate final DRs after expiration interval
-- Changes: 
--	2020-06-22 - Created
-- =============================================
CREATE PROCEDURE sms.job_SmsLog_ExpiredDR	
AS BEGIN

	INSERT INTO sms.DlrToProcess (Umid, StatusId, InProcess, CreatedAt, ScheduledAt)
	SELECT sl.Umid, cfg.DRExpirationStatusId, 0, SYSUTCDATETIME() AS CreatedAt, SYSUTCDATETIME() AS ScheduledAt
	--SELECT TOP 100 *
	FROM sms.SmsLog AS sl WITH (NOLOCK, FORCESEEK)
		INNER JOIN rt.SupplierOperatorConfig cfg (NOLOCK) 
			ON sl.ConnUid = cfg.ConnUid AND sl.OperatorId = cfg.OperatorId
	WHERE 
		-- filter 1 day window	
		sl.CreatedTime < DATEADD(MINUTE, -cfg.DRExpirationInMin, SYSUTCDATETIME())
		AND sl.CreatedTime >= DATEADD(MINUTE, -cfg.DRExpirationInMin - 24*60 /* 1 day */, SYSUTCDATETIME())
		-- look only non-finilized statuses
		AND sl.StatusId IN (SELECT StatusId FROM sms.DimSmsStatus WHERE Final = 0)
		AND sl.SmsTypeId = 1 /* outbound only, obviously */

	RETURN 0;
END
