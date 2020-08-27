CREATE VIEW [rpt].[bi_AccountBillingInformation]
AS
	SELECT
        AccountId,
        SubscriptionDate
    from 
        dbo.AccountBillingInformation
