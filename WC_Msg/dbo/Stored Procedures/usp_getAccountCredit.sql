
-- =============================================
-- Author:		<Raju Gupta>
-- Create date: ><16-10-2014>
-- Description:	return account credit in old MS API
-- =============================================
CREATE PROCEDURE [dbo].[usp_getAccountCredit]
	@AccountId VARCHAR(50)
AS
BEGIN
	
	-- Anton 2018-07-24: Hard-coded restiction, who can use deprecated endpoint http://wms1.wavecell.com/getApi.asmx?op=GetAccountCredit
	IF @AccountId <> ('SMS.SG') RETURN

	SELECT 
		a.AccountId, 
		aw.Balance AS CreditEuro /* don't bother with currency conversion */, 
		aw.ValidBalance AS ValidCredit
	FROM cp.Account a (NOLOCK)
		INNER JOIN cp.AccountWallet aw (NOLOCK) ON a.AccountUid = aw.AccountUid
	WHERE a.AccountId = @AccountId
           
END
