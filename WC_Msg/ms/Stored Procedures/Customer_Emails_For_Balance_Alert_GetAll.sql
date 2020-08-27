-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-02-20
-- Description:	Cache customer emails for balance notifications
-- =============================================
CREATE PROCEDURE [ms].[Customer_Emails_For_Balance_Alert_GetAll]
AS
BEGIN
	SELECT
		[AccountId] AS AccountId,
		[EmailAddress] AS OpToEmail,
		[CCEmailAddress] AS OpCcEmail,
		[BCCEmailAddress] AS OpBccEmail,
		[SalesTOEmail] AS SalesToEmail,
		[SalesCCEmailAddress] AS SalesCcEmailAddress,
		[SalesBCCEmailAddress] AS SalesBccEmailAddress,
		[FinanceToEmailAddress] AS FinanceToEmailAddress,
		[FinanceCCEmailAddress] AS FinanceCcEmailAddress,
		[FinanceBCCEmailAddress] AS FinanceBccEmailAddress,
		[SupportToEmailAddress] AS SupportToEmailAddress,
		[SupportCCEmailAddress] AS SupportCcEmailAddress,
		[SupportBCCEmailAddress] AS SupportBccEmailAddress
	FROM [dbo].[Users] u
	WHERE u.Active = 1
END
