-- =============================================
-- Author: Anton Shchekalov
-- Description:	Auto population of some meta fields of accounts
-- Changes: 
--	2020-06-24 - Created
-- =============================================
CREATE PROCEDURE ms.job_AccountMeta_AutoCompute
AS BEGIN

	-- Calculate UsageStart date of new Accounts for SMS product in self-service mode (OnboardingStatus=Created)
	-- Business rule: Account sent at least 100 accepted SMS in total. First date of SMS traffic is used as service start.
	WITH sa AS (
		SELECT apm.AccountId, a.AccountUid
		FROM ms.AccountProductMeta AS apm
			INNER JOIN cp.Account AS a ON apm.AccountId = a.AccountId
		WHERE apm.Product = 'SM' AND apm.OnboardingStatus = 'Created'
			AND apm.UsageStartLive IS NULL
	),
	stat AS (
		SELECT s.AccountUid, MIN(s.Date) AS StartDate
		FROM sms.StatSmsLogDaily s (NOLOCK)
		WHERE s.Date > DATEADD(MONTH, -1, SYSUTCDATETIME())
		GROUP BY s.AccountUid
		HAVING SUM(s.SmsCountTotal-s.SmsCountRejected) > 50 -- At least 100 accepted SMS in total
	)
	UPDATE m SET UsageStartLive = stat.StartDate
	--SELECT *
	FROM sa
		INNER JOIN stat ON sa.AccountUid = stat.AccountUid
		INNER JOIN ms.AccountProductMeta m ON m.AccountId = sa.AccountId AND m.Product = 'SM';

	RETURN 0;
END
