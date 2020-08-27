

CREATE VIEW [rpt].[bi_AccountCredit]
AS
	SELECT AccountId, CreditEuro
	FROM dbo.AccountCredit (NOLOCK)
