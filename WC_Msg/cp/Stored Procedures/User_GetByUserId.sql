-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-28
-- =============================================
-- EXEC cp.User_GetByUserId @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468'
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2019-01-23  Rebecca              Added IsTrialAccount to output
-- 2019-03-26  Rebecca				Added TraffType, CustomerType to output
-- 2019-04-10  Nathanael            Added NeedMigrationFromV2 column to output
-- 2019-05-15  Rebecca				Rename NeedMigrationFromV2 to SiteVersion_MigrationEnabled & added SiteVersion_Current
-- 2019-08-20  Rebecca				Added default currency
-- 2020-03-05  Anton				3rd resultset - Feature toggles

CREATE PROCEDURE [cp].[User_GetByUserId]
	@UserId UNIQUEIDENTIFIER
AS
BEGIN

    SELECT TOP(1) u.UserId, u.[Login], u.[Login] as Email, u.SecretKey, u.Firstname, u.Lastname, 
        u.Phone, u.PhoneVerified, u.TimeZoneId, tz.TimeZoneName, tz.Country as TimeZoneCountry, 
        a.AccountId, a.AccountName, a.CompanyName, a.AccountUid, a.FreeCreditsOffer,
		SiteVersion_MigrationEnabled, SiteVersion_Current,
        IIF(am.BillingMode = 'POSTPAID', 1, 0) AS IsPostPaid, 
		am.Currency, c.CurrencyName, ISNULL(c.Symbol, c.Currency) Symbol,
        u.AccessLevel,
        u.PasswordExpiresAt,
        -- feature to show/hide SmsToSurvey page
        a.SmsToSurveyEnabled,
        -- feature to show/hide payment by PayPal in CP
        IIF(am.CustomerType = 'L' AND am.TrafficType IN ('INCONC', 'SCAM'), 0, 1) AS IsPaypalEnabled,
        -- feature to show/hide balance in CP
        IIF(am.CustomerType IN ('W', 'E') AND am.BillingMode = 'POSTPAID', 0, a.Flag_ShowBalance) AS Flag_ShowBalance,
        -- feature to show/hide UrlShorten section in CP
        IIF(EXISTS(
            SELECT 1 
            FROM ms.UrlShortenDomainSubAccount u
                INNER JOIN dbo.Account sa ON sa.SubAccountUid = u.SubAccountUid
            WHERE sa.AccountId = a.AccountId), 1, 0) AS Flag_UrlShorten,
        u.OptIn_Marketing,
		CASE WHEN wl.AccountUid IS NULL THEN 0 ELSE 1 END IsTrialAccount,
		am.TrafficType, am.CustomerType,
		a.Product_SMS, a.Product_CA, a.Product_VI, a.Product_VO
    FROM cp.[User] AS u
        INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
        LEFT JOIN mno.TimeZone tz ON u.TimeZoneId = tz.TimeZoneId
        LEFT JOIN ms.AccountMeta am ON a.AccountId = am.AccountId
		LEFT JOIN mno.Currency c WITH (NOLOCK) ON c.Currency = am.Currency
		OUTER APPLY	(SELECT TOP 1 AccountUid FROM ms.MsisdnWhitelist
				WHERE AccountUid = u.AccountUid ) wl
    WHERE u.UserId = @UserId AND u.DeletedAt IS NULL ;

	IF @@ROWCOUNT = 1
		UPDATE cp.[User] SET LastLoginAt = SYSUTCDATETIME()
		WHERE UserId = @UserId ;

	-- return user roles
	EXEC [cp].[UserAccess_RoleGet] @UserId = @UserId ;

	-- return special user features
	SELECT t.Feature, t.Enabled
	FROM 
		cp.[User] u
        INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
		INNER JOIN cp.AccountFeatureToggle t ON a.AccountId = t.AccountId
    WHERE u.UserId = @UserId AND u.DeletedAt IS NULL
    
END
