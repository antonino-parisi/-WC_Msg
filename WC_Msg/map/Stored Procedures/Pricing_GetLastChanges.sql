
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-02
-- Description:	Get Subaccounts with changed prices
-- =============================================
-- EXEC map.[Pricing_GetLastChanges] @CustomerGroupIds = '212,213,215,216', @PriceChangedSince = '2018-05-02 00:00'
-- EXEC map.[Pricing_GetLastChanges] @CustomerGroupIds = NULL, @PriceChangedSince = NULL
CREATE PROCEDURE [map].[Pricing_GetLastChanges]
	@CustomerGroupIds varchar(500) = NULL,  -- comma separated list, optional filter
	@PriceChangedSince smalldatetime = NULL	-- optional filter
AS
BEGIN
	
	--DECLARE @CustomerGroupIds varchar(500) = '212,213,215,216'
	--DECLARE @PriceChangedSince smalldatetime = NULL

	SELECT 
		cng.CustomerGroupId, 
		cng.SubAccountUid, 
		cng.ChangedItems, 
		cng.LastPriceChangedAt, 
		cg.CustomerGroupName, 
		sa.SubAccountId, 
		sa.PriceNotifiedAt
	FROM (
			SELECT cgc.CustomerGroupId, cgs.SubAccountUid, 
				COUNT(1) AS ChangedItems,
				MAX(cgc.PriceChangedAt) AS LastPriceChangedAt
			--select *
			FROM rt.CustomerGroupCoverage cgc
				INNER JOIN rt.CustomerGroupSubAccount cgs 
					ON cgc.CustomerGroupId = cgs.CustomerGroupId AND (cgc.SubAccountUid IS NULL OR cgc.SubAccountUid = cgs.SubAccountUid) AND cgs.Deleted = 0
			WHERE cgc.Deleted = 0
				--AND cgc.TrafficCategory = 'DEF' -- NB: temporary. Should be removed in future
				-- filter by last price changed
				AND (cgc.PriceChangedAt >= @PriceChangedSince OR @PriceChangedSince IS NULL)
				-- filter by list of Customer Groups
				AND (@CustomerGroupIds IS NULL OR cgc.CustomerGroupId IN (SELECT Item FROM dbo.SplitString_Int (@CustomerGroupIds, ',')))
			GROUP BY cgc.CustomerGroupId, cgs.SubAccountUid) cng
		INNER JOIN dbo.Account sa ON sa.SubAccountUid = cng.SubAccountUid
		INNER JOIN rt.CustomerGroup cg ON cg.CustomerGroupId = cng.CustomerGroupId AND cg.Deleted = 0

END
