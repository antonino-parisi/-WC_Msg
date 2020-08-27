-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-12-11
-- Description:	Get account credit info given AccountUid
-- =============================================
-- EXEC map.AccountCredit_Get @AccountUid='DBC09EF1-8806-EA11-8158-06B9B96CA965'

CREATE PROCEDURE [map].[AccountCredit_Get]
	@AccountUid uniqueidentifier
AS
BEGIN
	SELECT 
		a.AccountName, 
		a.AccountUid, 
		a.AccountId, 
		ar.[Date],
		ar.Record, 
		mno.CurrencyConverter(ar.Value, ar.Currency, 'EUR', DEFAULT) AS Value, -- EUR for backward compatibility
		-- ar.Value <-- uncomment when ready to support "Currency" column
		ar.Currency,
		ISNULL(u.FirstName, '') + ' ' + ISNULL(u.LastName, '') UpdatedBy,
		u.[Login] AS UpdateByEmail, ar.UpdatedAt    
	FROM cp.Account a
		INNER JOIN dbo.AccountRecord ar ON a.AccountId = ar.AccountId
		LEFT JOIN cp.[User] u ON ar.UpdatedBy = u.UserId
	WHERE a.AccountUid = @AccountUid
	ORDER BY ar.[Date] DESC ;

END
