-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-12-11
-- Description:	Get account info given AccountUid
-- =============================================
-- EXEC map.AccountMeta_Get @AccountUid='A4202809-C3CD-E711-8144-02D85F55FCE7'
CREATE PROCEDURE [map].[AccountMeta_Get]
	@AccountUid uniqueidentifier
AS
BEGIN

	SELECT 
		a.AccountName, a.AccountUid, a.AccountId, IIF(am.AccountId IS NULL, 0, 1) HasAccountMeta,
		am.CustomerType, 
		--am.CompanyEntity AS EntityCountryISO, -- deprecated
		am.CompanyEntity, 
		am.BillingMode, m.ManagerId, m.[Name] AS Manager, 
		am.MainContact, am.MainContactEmail, am.EmergencyContact1 TechContactEmail,
		am.EmergencyContact2 OpsContactEmail, am.CustomerCategory, am.Currency,
		am.Connectiontype, am.UsesWebsender, am.TrafficType, am.VPN, am.OnboardingStatus,
		am.CompanySize, 
		-- CAST('2020-01-01' as date) AS UsageStart, -- deprecated
		am.SalesforceCustomerId, uc.User_Count_Active, uc.User_Count_Invited, uc.User_Count_Blocked,
		uc.User_Count, s.SubAccount_Count, 
		mno.CurrencyConverter(aw.Balance, aw.Currency, 'EUR', DEFAULT) AS CreditEuro, -- deprecated
		aw.Currency AS WalletCurrency,
		aw.Balance AS WalletBalance,
		ISNULL(u.FirstName, '') + ' ' + ISNULL(u.LastName, '') AS UpdatedBy,
		u.Email AS UpdateByEmail, am.UpdatedAt                    
	FROM cp.Account a
		LEFT JOIN ms.AccountMeta am ON a.AccountId = am.AccountId
		LEFT JOIN ms.AccountManager m ON am.ManagerId = m.ManagerId
		LEFT JOIN map.[User] u ON am.MapUpdatedBy = u.UserId
		LEFT JOIN cp.AccountWallet aw WITH (NOLOCK) ON a.AccountUid = aw.AccountUid
		OUTER APPLY (SELECT SUM(IIF(UserStatus='A', 1, 0)) User_Count_Active, SUM(IIF(UserStatus='I', 1, 0)) User_Count_Invited,
							SUM(IIF(UserStatus='B', 1, 0)) User_Count_Blocked, COUNT(1) User_Count
							FROM cp.[User] WHERE AccountUid = @AccountUid) uc
		OUTER APPLY (SELECT COUNT(1) SubAccount_Count FROM ms.SubAccount WHERE AccountUid = @AccountUid) s
	WHERE a.AccountUid = @AccountUid ;

	SELECT IIF(Total = [Inactive], 1, 0) ActivateButton
	FROM
		(SELECT COUNT(1) Total, SUM(IIF([Active] = 0, 1, 0)) [Inactive]
		FROM ms.SubAccount
		WHERE AccountUid = @AccountUid 
		) a ;

END
