CREATE VIEW [rpt].[bi_Account]
AS
Select
	d.AccountId,
	d.SubAccountId,
	d.Description,
	d.TrafficRecording,
	d.Active,
	d.[Default],
	d.Date,
	d.IsTrafficReport,
	d.StandardRouteId,
	d.PricingFormula,
	d.IsPriceChangeAlert,
	d.BlockedRoutes,
	d.IsBalanceOrOverdraftAlert,
	d.SubAccountUid,
	d.UpdatedAt,
	d.Deleted,
	d.QueueType,
	d.QueueKey,
	c.AccountUid,
	c.AccountName,
	c.CompanyName,
	c.Country,
	c.CompanyAddress,
	c.InvoiceEmails,
	c.AccountCurrency,
	c.CreatedAt,
	c.Billing_StripeId,
	c.Billing_PaypalId,
	c.FreeCreditsOffer,
	c.IsV2Allowed,
	0 AS IsV1Allowed,
	c.SmsToSurveyEnabled
from
	dbo.account d 
LEFT JOIN 
	cp.account c ON d.accountid = c.accountid
