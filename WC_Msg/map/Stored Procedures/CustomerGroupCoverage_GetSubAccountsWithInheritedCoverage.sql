-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-04-11
-- =============================================
-- EXEC map.CustomerGroupCoverage_GetSubAccountsWithInheritedCoverage @CustomerGroupId = 235, @Country = 'SG', @OperatorId = 525001, @TrafficCategory = 'DEF'
CREATE PROCEDURE [map].[CustomerGroupCoverage_GetSubAccountsWithInheritedCoverage]
	@CustomerGroupId int,	--filter
	@Country char(2),		--filter
	@OperatorId int,		--filter
	@TrafficCategory varchar(3) = 'DEF'	--filter
AS
BEGIN

	-- Main select
	SELECT cgs.SubAccountUid
	FROM rt.CustomerGroupSubAccount cgs
	WHERE cgs.Deleted = 0 AND cgs.CustomerGroupId = @CustomerGroupId
		AND NOT EXISTS (
			SELECT 1 
			FROM rt.CustomerGroupCoverage cgc
			WHERE cgc.CustomerGroupId = @CustomerGroupId AND cgc.Deleted = 0
				AND cgc.SubAccountUid = cgs.SubAccountUid
				AND Country = @Country 
				AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
				AND TrafficCategory = ISNULL(@TrafficCategory, 'DEF')
		)
		AND EXISTS (
			SELECT 1 
			FROM rt.CustomerGroupCoverage cgc
			WHERE cgc.CustomerGroupId = @CustomerGroupId AND cgc.Deleted = 0
				AND cgc.SubAccountUid IS NULL
				AND Country = @Country 
				AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
				AND TrafficCategory = ISNULL(@TrafficCategory, 'DEF')
		)
END
