-- =============================================
-- Author:		Alexjander Bacalso
-- Create date: 2020-06-10
-- Description: GetAll billing top-up minimum for each currency
-- =============================================
-- EXEC cp.BillingTopupMin_GetAll
-- =============================================
CREATE PROCEDURE [cp].[BillingTopupMin_GetAll]
AS
BEGIN
	SELECT Currency, Amount
	FROM cp.BillingTopupMin
END
