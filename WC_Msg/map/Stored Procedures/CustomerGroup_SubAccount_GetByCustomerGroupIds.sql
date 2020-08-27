-- =============================================
-- Author:		    Raymond Torino
-- Created date:    2018-04-24
-- =============================================
-- EXEC map.CustomerGroup_SubAccount_Get @CustomerGroupIds = '4'

CREATE PROCEDURE [map].[CustomerGroup_SubAccount_GetByCustomerGroupIds]
	@CustomerGroupIds VARCHAR(1000) = NULL,
    @TimePeriodInMins int = 30
AS
BEGIN
    SELECT 
		cgs.CustomerGroupId, 
        cg.CustomerGroupName, 
        cgs.SubAccountUid, 
        sa.SubAccountId, 
        a.AccountId, 
        sa.AccountUid,
        cgs.UpdatedAt,
        sa.PriceNotifiedAt,
        DATEADD(MINUTE, @TimePeriodInMins, cgs.UpdatedAt) as tae
	FROM 
		rt.CustomerGroupSubAccount cgs
			INNER JOIN ms.SubAccount sa ON cgs.SubAccountUid = sa.SubAccountUid
			INNER JOIN rt.CustomerGroup cg ON cgs.CustomerGroupId = cg.CustomerGroupId
			INNER JOIN cp.Account a ON a.AccountUid = a.AccountUid
    WHERE 
		((@CustomerGroupIds IS NULL AND cgs.CustomerGroupId IS NOT NULL) 
            OR (@CustomerGroupIds IS NOT NULL AND cgs.CustomerGroupId IN (SELECT * FROM dbo.SplitString(@CustomerGroupIds, ','))))
        AND ((@TimePeriodInMins <> 0 AND DATEADD(MINUTE, @TimePeriodInMins, cgs.UpdatedAt) >= SYSUTCDATETIME())
            OR (@TimePeriodInMins = 0))
        AND cgs.Deleted = 0
        AND cg.Deleted = 0
END
