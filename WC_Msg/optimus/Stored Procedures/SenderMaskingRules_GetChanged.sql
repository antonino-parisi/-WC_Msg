-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-09-18
-- Description:	Get all or changed data for SenderMaskingRules
-- Higher value of 'Priority' means higher priority of record inside OperatorId + RuouteId
-- =============================================
-- EXEC ms.DbDependency_DataChanged @Key = 'Optimus.SenderId.Rules'
-- EXEC [optimus].[SenderMaskingRules_GetChanged] @LastSync = '2019-05-01'
CREATE PROCEDURE [optimus].[SenderMaskingRules_GetChanged]
	@LastSync datetime = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		r.RuleId, 
		r.Country, 
		r.OperatorId, 
		c.ConnUid,
		r.CustomerType,	/* E, W, L, I */
		r.AccountId,
		sa.SubAccountUid,
		r.SenderIdFilterType,
		r.OriginalSenderId,
		r.OriginalSenderId AS OriginalSenderIdPattern, /* backward compatibility */ 
		r.Priority, 
		r.NewSenderId,
		r.NewSenderPoolId,
		r.Deleted
	FROM optimus.SenderMaskingRules r
		LEFT JOIN dbo.Account sa ON r.SubAccountId = sa.SubAccountId
		LEFT JOIN rt.SupplierConn c ON c.ConnId = r.RouteId
	WHERE --(r.NewSenderId IS NOT NULL OR r.NewSenderPoolId IS NOT NULL) AND 
		  ((@LastSync IS NULL AND r.Deleted = 0)
			OR (@LastSync IS NOT NULL AND r.UpdatedAt >= @LastSync))
			AND (r.RouteId IS NULL OR c.ConnUid IS NOT NULL)
	--ORDER BY OperatorId, RouteId, Priority DESC
END
