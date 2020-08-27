
-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-02
-- =============================================
-- SAMPLE:
-- EXEC rt.[job_RoutingConsistency_Validate]
CREATE PROCEDURE [rt].[job_RoutingConsistency_Validate]
AS
BEGIN
	IF EXISTS (
		SELECT TOP (1) 1
		--SELECT *
		FROM rt.RoutingTier (NOLOCK)
		WHERE TierLevel > 50 AND Deleted = 0

		--UPDATE rt.RoutingTier SET TierLevel = 4 WHERE RoutingTierId = 26247
	)
		THROW 51000, 'WARNING: There are RoutingTiers with TierLevel > 50', 1;  

	PRINT dbo.Log_ROWCOUNT ('Checked: RoutingTiers with TierLevel > 50')

	IF EXISTS (
		SELECT TOP 10 rc.CostCalculated AS RP_Cost, rt.CostCalculated AS T_Cost, * 
		FROM rt.RoutingPlanCoverage rc (NOLOCK)
			INNER JOIN rt.RoutingTier rt (NOLOCK) ON rc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 AND rt.Deleted = 0 AND rc.Deleted = 0
		WHERE ISNULL(rc.CostCalculated, 0) <> rt.CostCalculated
	)
		THROW 51001, 'WARNING: There are CostCalculated mismatch in RoutingPlan', 1;  
	PRINT dbo.Log_ROWCOUNT ('Checked: CostCalculated mismatch in RoutingPlan')

	IF EXISTS (
		SELECT TOP 1000 cgc.CostCalculated AS CG_Cost, rc.CostCalculated AS RP_Cost, rt.CostCalculated AS T_Cost, * 
		FROM rt.CustomerGroupCoverage cgc (NOLOCK)
			INNER JOIN rt.RoutingPlanCoverage rc (NOLOCK) ON cgc.RoutingGroupId = rc.RoutingGroupId
			INNER JOIN rt.RoutingTier rt (NOLOCK) ON cgc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 AND rt.Deleted = 0
		WHERE ISNULL(cgc.CostCalculated, 0) <> rt.CostCalculated
			AND cgc.Deleted = 0
			
		/* fix
		UPDATE rt.RoutingTier SET CostCalculated = CostCalculated 
		where RoutingTierId IN (
			SELECT DISTINCT rt.RoutingTierId 
			FROM rt.vwCustomerGroupCoverage cgc (NOLOCK)
				INNER JOIN rt.vwRoutingPlanCoverage rc (NOLOCK) ON cgc.RoutingGroupId = rc.RoutingGroupId
				INNER JOIN rt.vwRoutingTier rt (NOLOCK) ON cgc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 AND rt.Deleted = 0
			WHERE ISNULL(cgc.CostCalculated, 0) <> rt.CostCalculated
				AND cgc.Deleted = 0
		)
		*/
	)
		THROW 51002, 'WARNING: There are CostCalculated mismatch in CustomerGroup', 1;  
	PRINT dbo.Log_ROWCOUNT ('Checked: CostCalculated mismatch in CustomerGroup')

	IF EXISTS (
		SELECT RoutingGroupId, count(*)
		FROM rt.RoutingPlanCoverage rpc (NOLOCK)
			INNER JOIN rt.RoutingPlan rp (NOLOCK) ON rpc.RoutingPlanId = rp.RoutingPlanId
		WHERE rpc.Deleted = 0 and rp.Deleted = 0
		GROUP BY RoutingGroupId
		HAVING count(RoutingGroupId) > 1
	)
		THROW 51003, 'WARNING: Same RoutingGroupId is attached to multiple RoutingPlans', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: RoutingGroupId is not attached to multiple RoutingPlans')

	IF EXISTS (
		--SELECT TOP 10 *
		----UPDATE rt SET UpdatedAt = rt.UpdatedAt
		--FROM rt.RoutingTier rt (NOLOCK)
		--	INNER JOIN rt.RoutingGroup rg (NOLOCK) ON  rt.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--	INNER JOIN rt.RoutingPlanCoverage rpc (NOLOCK) ON rpc.RoutingGroupId = rg.RoutingGroupId AND rpc.Deleted = 0
		--	INNER JOIN rt.RoutingTierConn rtc (NOLOCK) ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0 
		--	INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON scc.OperatorId = rpc.OperatorId AND scc.RouteUid = rtc.ConnUid AND scc.Deleted = 0
		--WHERE rt.CostCalculated IS NULL
		
		SELECT TOP 10 *
		--UPDATE rt SET UpdatedAt = rt.UpdatedAt
		FROM rt.RoutingTier rt
			INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 
			INNER JOIN (
				SELECT rtc.RoutingTierId, 
					scc.Country, scc.OperatorId,
					'EUR' AS Currency,
					SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight) AS CostCalculated
				FROM rt.RoutingTierConn rtc (NOLOCK)
					--INNER JOIN rt.vwSupplierCostCoverage_Active (NOLOCK) scc 
					INNER JOIN rt.SupplierConn sc (NOLOCK) ON sc.ConnUid = rtc.ConnUid
					INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
						scc.RouteUid = sc.ConnUid 
						AND scc.Deleted = 0 AND scc.SmsTypeId = 1
						AND scc.EffectiveFrom <= SYSUTCDATETIME()
				WHERE rtc.Deleted = 0
				GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId
			) rtc ON rt.RoutingTierId = rtc.RoutingTierId AND 
					rtc.Country = rpc.Country AND
					ISNULL(rtc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
		WHERE rt.Deleted = 0
			AND (rt.CostCalculated IS NULL OR rt.CostCalculated <> rtc.CostCalculated)
	)
	BEGIN
		UPDATE rt SET UpdatedAt = rt.UpdatedAt
		FROM rt.RoutingTier rt
			INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 
			INNER JOIN (
				SELECT rtc.RoutingTierId, 
					scc.Country, scc.OperatorId,
					'EUR' AS Currency,
					SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight) AS CostCalculated
				FROM rt.RoutingTierConn rtc (NOLOCK)
					--INNER JOIN rt.vwSupplierCostCoverage_Active (NOLOCK) scc 
					INNER JOIN rt.SupplierConn sc (NOLOCK) ON sc.ConnUid = rtc.ConnUid
					INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
						scc.RouteUid = sc.ConnUid 
						AND scc.Deleted = 0 AND scc.SmsTypeId = 1
						AND scc.EffectiveFrom <= SYSUTCDATETIME()
				WHERE rtc.Deleted = 0
				GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId
			) rtc ON rt.RoutingTierId = rtc.RoutingTierId AND 
					rtc.Country = rpc.Country AND
					ISNULL(rtc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
		WHERE rt.Deleted = 0
			AND (rt.CostCalculated IS NULL OR rt.CostCalculated <> rtc.CostCalculated);

		THROW 51004, 'WARNING: RoutingTier with CostCalculated=NULL OR inconsistent CostCalculated', 1; 
	END
	PRINT dbo.Log_ROWCOUNT ('Checked: No RoutingTiers with inconsistent CostCalculated')

	IF EXISTS (
		SELECT TOP 10 rc.CostCalculated AS RP_Cost, rt.CostCalculated AS T_Cost 
		FROM rt.RoutingPlanCoverage rc (NOLOCK)
			INNER JOIN rt.RoutingTier rt (NOLOCK) ON rc.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 /*AND rc.RoutingPlanId = rt.RoutingPlanId*/ AND rt.Deleted = 0 AND rc.Deleted = 0
		WHERE 
			ISNULL(rc.CostCalculated, 0) <> rt.CostCalculated
	)
		THROW 51004, 'WARNING: CostCalculated in RoutingTier/L1 and RoutingPlanCoverage are not matching', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: CostCalculated in RoutingTier/L1 and RoutingPlanCoverage are matching')

	IF EXISTS (
		SELECT TOP 100 * 
		FROM [rt].[vwRoutingTierConnMap] (NOLOCK)
		WHERE TierLevel < TierLevelCurrent AND Active = 1 AND Deleted = 0 AND RT_Deleted = 0

		/* fix
		update rg set TierLevelCurrent = rt.TierLevel
		from rt.RoutingGroup rg
			INNER JOIN  rt.RoutingTier rt ON rt.RoutingGroupId = rg.RoutingGroupId AND rt.TierLevel = 1 and rt.Deleted = 0
			inner join rt.RoutingTierConn rtc on rt.RoutingTierId = rtc.RoutingTierId and rtc.Active = 1
		where rg.TierLevelCurrent > rt.TierLevel and rg.Deleted = 0 and rtc.Deleted = 0
		*/
	)
		THROW 51005, 'ERROR: Current TierLevel is not using primary active Tier', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: Current TierLevel is using primary active Tier')

	IF EXISTS (
		SELECT *
		FROM rt.vwRoutingPlanCoverageAllConn v
		WHERE v.Deleted = 0 AND v.RP_Deleted = 0 AND v.RG_Deleted = 0 AND v.RT_Deleted = 0 
			and v.CostCalculated is null
			and v.ConnUid is null

		/* fix
		select *
		from rt.RoutingTier rt
		where rt.RoutingGroupId = 23346 
			and Deleted = 0
		order by TierLevel

		update rt.RoutingTier set Deleted = 1 where RoutingTierId IN (27018)
		update rt.RoutingTier set TierLevel = TierLevel - 1 where RoutingTierId IN (27020)
		*/
	)
		THROW 51005, 'ERROR: Tier has no connections attached', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: All active tiers have attached connections')

	IF EXISTS (
		SELECT TOP (10) *
		--UPDATE cgc SET RoutingPlanId = rpc_ByGroup.RoutingPlanId
		--UPDATE cgc SET RoutingGroupId = rpc_ByPlan.RoutingGroupId
		FROM 
			rt.CustomerGroupCoverage (NOLOCK) cgc
			INNER JOIN rt.RoutingPlanCoverage rpc_ByGroup (NOLOCK) ON 
				rpc_ByGroup.RoutingGroupId = cgc.RoutingGroupId AND
				rpc_ByGroup.OperatorId = cgc.OperatorId AND
				rpc_ByGroup.Deleted = 0
			--INNER JOIN rt.RoutingPlanCoverage rpc_ByPlan (NOLOCK) ON 
			--	rpc_ByPlan.RoutingPlanId = cgc.RoutingPlanId AND
			--	rpc_ByPlan.OperatorId = cgc.OperatorId AND
			--	rpc_ByPlan.Deleted = 0
		WHERE cgc.Deleted = 0 AND rpc_ByGroup.RoutingPlanId <> cgc.RoutingPlanId
		--SELECT * FROM rt.RoutingPlan rp WHERE rp.RoutingPlanId IN (26,37)
		--SELECT * FROM rt.RoutingPlanCoverage rpc WHERE rpc.RoutingPlanId IN (26,37) AND rpc.OperatorId = 310000 AND rpc.Deleted = 0
	)
		THROW 51006, 'ERROR: RoutingPlanId and RoutingGroupId doesn''t match in CustomerGroupCoverage', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: RoutingPlanId and RoutingGroupId match in CustomerGroupCoverage')

	IF EXISTS (
		SELECT rt.RoutingGroupId, rt.TierLevel, COUNT(DISTINCT rt.RoutingTierId) AS TierCnt
		FROM rt.RoutingPlanCoverage rpc
			INNER JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
			INNER JOIN rt.RoutingTier rt ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0
		WHERE rpc.Deleted = 0
		GROUP BY rt.RoutingGroupId, rt.TierLevel
		HAVING COUNT(DISTINCT rt.RoutingTierId) > 1

		/* fixing
		select * from rt.RoutingTier where RoutingGroupId = 24192 order by TierLevel
		update rt.RoutingTier set TierLevel = 6 where RoutingTierId = 35590
		*/
	)
		THROW 51007, 'ERROR: More than 1 RoutingTier in same TierLevel', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: More than 1 RoutingTier in same TierLevel')

	IF EXISTS (
		SELECT TOP 100 rt.RoutingGroupId--, (COUNT(rt.RoutingTierId)+1) / AVG(cast(rt.TierLevel as decimal(5,2))), COUNT(rt.RoutingTierId) AS Count, AVG(cast(TierLevel as decimal(5,2))), AVG(cast(TierLevel as decimal(5,2)))*2 AS AVG, MAX(TierLevel) as Max
		FROM rt.RoutingTier rt
			INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rt.RoutingGroupId AND rpc.Deleted = 0
		WHERE rt.Deleted = 0
		GROUP BY rt.RoutingGroupId
		HAVING (COUNT(rt.RoutingTierId)+1) / AVG(cast(rt.TierLevel as decimal(5,2))) <> 2

		/* fixing
		select * from rt.RoutingTier where RoutingGroupId = 25356 and Deleted = 0 order by TierLevel
		update rt.RoutingTier set TierLevel = 4 where RoutingTierId = 38965
		update rt.RoutingTier set TierLevel = TierLevel-1 where RoutingGroupId = 25356 and TierLevel >= 4 and Deleted = 0
		*/

	)
		THROW 51008, 'ERROR: There is corrupted sequence of TierLevels', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: There are no corrupted TierLevel sequences')


	IF EXISTS (
		SELECT TOP 100 sl.UMID, sl.CreatedTime, sl.Cost AS Cost_SmsLog, round(scc.CostEUR,6) As Cost_Expected, sl.CostContractPerSms, sl.CostContractCurrency, scc.CostLocal, scc.CostLocalCurrency, *
		--SELECT TOP 100 *
		FROM sms.SmsLog sl (NOLOCK)
			INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
				scc.RouteUid = sl.ConnUid
				AND scc.Country = sl.Country
				AND scc.OperatorId = sl.OperatorId 
				AND sl.SmsTypeId = scc.SmsTypeId
				AND scc.Deleted = 0
				AND sl.CreatedTime >= DATEADD(MINUTE, 2, scc.UpdatedAt)
			LEFT JOIN rt.SupplierCostCoverageSID sccs ON scc.RouteUid = sccs.ConnUid AND scc.Country = sccs.Country AND scc.OperatorId = ISNULL(sccs.OperatorId, scc.OperatorId)
			LEFT JOIN rt.SupplierOperatorConfig AS soc ON soc.ConnUid = sl.ConnUid AND soc.OperatorId = sl.OperatorId AND soc.ChargeOnDelivery = 1
		WHERE 
			sl.CreatedTime > DATEADD(HOUR, -2, GETUTCDATE())
			AND sl.CreatedTime < GETUTCDATE()
			--AND sl.CreatedTime >= '2018-10-25 08:32'
			--and sl.SubAccountId not like 'csg%'
			--AND sl.SubAccountId NOT IN ('SMST_035') -- SmsRouter v1
			AND sl.CostContractCurrency = scc.CostLocalCurrency
			AND (
				(soc.ConfigId IS NULL AND ABS(sl.CostContractPerSms - scc.CostLocal) >= 0.0001)
				OR 
				(soc.ConfigId IS NOT NULL AND sl.StatusId IN (31,40) AND sl.CostContractPerSms = 0)
			)
			AND NOT EXISTS (SELECT TOP 1 1 FROM ms.FeatureFilter_SmsRouter f WHERE f.SubAccountId = sl.SubAccountId and sl.Country = ISNULL(f.Country, sl.Country) AND f.IsActive = 0)
			AND sl.OperatorId <> 310000 -- America +1 issue
			AND sl.StatusId IN (30, 40, 50)
			AND sl.SubAccountId NOT IN (SELECT DISTINCT sa.SubAccountId FROM cls.ClassificationRule cr JOIN ms.SubAccount sa ON cr.SubAccountUid = sa.SubAccountUid)
			AND sccs.CostCoverageSIDId IS NULL
		/*
		WITH q AS (
			SELECT DISTINCT TOP 100 scc.RouteUid, scc.OperatorId, sl.Cost
			--SELECT TOP 100 sl.
			FROM sms.SmsLog sl (NOLOCK)
				INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
					scc.RouteUid = sl.ConnUid 
					AND scc.OperatorId = sl.OperatorId 
					AND scc.Deleted = 0
					AND sl.CreatedTime >= DATEADD(MINUTE, 1, scc.UpdatedAt)
			WHERE sl.SubAccountId IN (
					SELECT SubAccountId FROM ms.FeatureFilter_SmsRouter WHERE ApiVersion = 'v2' and IsActive = 1)
				and sl.CreatedTime > DATEADD(HOUR, -5, GETUTCDATE())
				--and sl.SubAccountId not like 'csg%'
				and ABS(sl.Cost - scc.CostEUR) >= 0.00001
		)
		--SELECT * 
		UPDATE scc SET UpdatedAt = SYSUTCDATETIME()
		FROM q
			INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
					scc.RouteUid = q.RouteUid 
					AND scc.OperatorId = q.OperatorId 
					AND scc.Deleted = 0
		;

		SELECT * FROM ext.SupplierCostCoverage_Log WHERE EventTime BETWEEN '2018-11-01 08:14' and '2018-11-01 08:25'
		*/

	)
		THROW 51009, 'ERROR: Cost in SmsLog doesn''t match real Supplier Cost', 1; 
	PRINT dbo.Log_ROWCOUNT ('Checked: Cost in SmsLog matches real Supplier Cost')

END