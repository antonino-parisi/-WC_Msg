-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-18
-- Description:	get data for SenderMaskingRules
--	Higher value of 'Priority' means higher priority of record inside OperatorId + RuouteId
-- =============================================
CREATE PROCEDURE [optimus].[SenderMaskingRules_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		RuleId, 
		r.Country, 
		ISNULL(r.OperatorId, o.OperatorId) AS OperatorId, 
		RouteId, 
		ISNULL(r.SubAccountId, sa.SubAccountId) SubAccountId, 
		OriginalSenderId AS OriginalSenderIdPattern, 
		Priority, 
		NewSenderId, 
		NewSenderPoolId
	FROM optimus.SenderMaskingRules r
		LEFT JOIN mno.Operator o ON r.Country = o.CountryISO2alpha AND r.OperatorId IS NULL
		LEFT JOIN dbo.Account sa ON r.AccountId = sa.AccountId AND r.SubAccountId IS NULL
	WHERE (r.NewSenderId IS NOT NULL OR r.NewSenderPoolId IS NOT NULL)
		AND r.RouteId IS NOT NULL
		AND r.Deleted = 0 AND r.SenderIdFilterType = 'P' AND r.CustomerType IS NULL
	UNION ALL
	-- case to support ALL operators of country
    SELECT RuleId, r.Country, 0 AS OperatorId, RouteId, SubAccountId, OriginalSenderId AS OriginalSenderIdPattern, Priority, NewSenderId, NewSenderPoolId
	FROM optimus.SenderMaskingRules r
	WHERE r.OperatorId IS NULL 
		AND (r.NewSenderId IS NOT NULL OR r.NewSenderPoolId IS NOT NULL)
		AND r.RouteId IS NOT NULL
		AND r.Deleted = 0 AND r.SenderIdFilterType = 'P' AND r.CustomerType IS NULL
	ORDER BY OperatorId, RouteId, Priority DESC
END
