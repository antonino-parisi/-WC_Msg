-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-05-28
-- Description:	anonymisation of mobile phone with GDPR compliance
-- =============================================
CREATE PROCEDURE sms.GDPR_MsisdnAnonymise
	@Msisdn BIGINT,
	@AccountUid UNIQUEIDENTIFIER
AS
BEGIN

	--- TODO: optimize to find UMIDs first without locking table
    -- anonymization in ChatApps logs
	UPDATE sl 
	SET MSISDN = sl.MSISDN / 10000
	FROM sms.SmsLog sl
		INNER JOIN ms.vwSubAccount sa ON sa.SubAccountUid = sl.SubAccountUid
	WHERE sl.MSISDN = @Msisdn AND 
		(@AccountUid IS NULL OR (@AccountUid IS NOT NULL AND sa.AccountUid = @AccountUid ))

	-- anonymization in ChatApps logs
	UPDATE il
	SET MSISDN = il.MSISDN / 10000
	FROM sms.IpmLog il
		INNER JOIN ms.vwSubAccount sa ON sa.SubAccountUid = il.SubAccountUid
	WHERE il.MSISDN = @Msisdn AND 
		(@AccountUid IS NULL OR (@AccountUid IS NOT NULL AND sa.AccountUid = @AccountUid ))

END
