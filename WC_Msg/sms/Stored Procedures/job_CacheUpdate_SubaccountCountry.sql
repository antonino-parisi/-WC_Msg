-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-05-23
-- Description:	Update cache of used countries by each SubAccount
-- =============================================
CREATE PROCEDURE [sms].[job_CacheUpdate_SubaccountCountry]
AS
BEGIN

	INSERT INTO sms.CacheSubaccountCountryLog (SubAccountUid, Country)
	SELECT DISTINCT sl.SubAccountUid, sl.Country
	FROM sms.StatSmsLog sl
	WHERE sl.TimeFrom >= DATEADD(DAY, -2, GETUTCDATE()) AND sl.TimeFrom < DATEADD(HOUR, -1, GETUTCDATE())
		AND sl.Country IS NOT NULL
		AND NOT EXISTS (SELECT 1 FROM sms.CacheSubaccountCountryLog ca WHERE ca.SubAccountUid = sl.SubAccountUid AND ca.Country = sl.Country)
END

