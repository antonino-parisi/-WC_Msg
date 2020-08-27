-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-11-03
-- Description:	Sync RoutingData from MessageSphere v1
-- =============================================
-- EXEC [rt].[job_SyncRoutingFromv1]
CREATE PROCEDURE [rt].[job_SyncRoutingFromv1]
AS
BEGIN

	SET NOCOUNT ON;

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Starting sync'

	--------------------------
	-- SupplierConn
	--------------------------
	--select * from rt.SupplierConn t full join dbo.CarrierConnections s ON t.ConnUid = s.RouteUid
	MERGE rt.SupplierConn AS t
	USING (
		SELECT RouteId, RouteUid, CAST(1 - Active as bit) AS Deleted 
		FROM dbo.CarrierConnections
	) AS s
	ON (t.ConnUid = s.RouteUid)
	WHEN MATCHED AND (t.ConnId <> s.RouteId OR s.Deleted <> t.Deleted)
		THEN UPDATE SET t.ConnId = s.RouteId, t.Deleted = s.Deleted
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (ConnUid, ConnId, Deleted, IsConnected) VALUES (s.RouteUid, s.RouteId, s.Deleted, 1)
	WHEN NOT MATCHED BY SOURCE AND t.Deleted = 0
		THEN UPDATE SET Deleted = 1, IsConnected = 0;
 
	PRINT dbo.Log_ROWCOUNT ('rt.SupplierConn - merge')


	--------------------------
	-- Routing Plans
	--------------------------

	IF(OBJECT_ID('tempdb..##RoutingSync') IS NOT NULL) DROP TABLE ##RoutingSync

	CREATE TABLE ##RoutingSync (
		RP_Id int NULL,
		RP_Name varchar(100) NOT NULL,
		RP_Description varchar(500) NOT NULL,
		PP_Id int NULL,
		PP_Name varchar(100) NOT NULL,
		PP_Description varchar(500) NOT NULL,
		RPC_Id int NULL,
		RPC_Country char(2) NULL,
		RPC_OperatorId int NULL,
		RPC_RoutingGroupId int NULL,
		RPC_CostCurrency varchar(3) NOT NULL,
		RPC_CostCalculated decimal(12,6) NULL,
		PPC_Id int NULL,
		PPC_Country char(2) NULL,
		PPC_OperatorId int NULL,
		PPC_Currency varchar(3) NOT NULL,
		PPC_Price decimal(12,6) NULL,
		PPC_MarginRate decimal(8,4) NULL,
		PPC_PricingFormulaId int NULL,
		RG_Id int NULL,
		RG_RoutingGroupName varchar(100) NULL,
		RGT_Level int NOT NULL,
		RT_Id int NULL,
		RT_RoutingTierName varchar(100) NULL,
		--RTC_Id int NULL,
		RTC_ConnId varchar(50) NOT NULL,
		RTC_ConnUid int NOT NULL,
		RTC_Weight int NOT NULL,
		RTC_Active bit NOT NULL
	)

	INSERT INTO ##RoutingSync (
		RP_Name,
		RP_Description,
		PP_Name,
		PP_Description,

		RPC_Country,
		RPC_OperatorId,
		RPC_RoutingGroupId,
		RPC_CostCurrency,
		RPC_CostCalculated,
		
		PPC_Country,
		PPC_OperatorId,
		PPC_Currency,
		PPC_Price,
		PPC_PricingFormulaId,
		
		RG_RoutingGroupName,
		RGT_Level,
		RT_RoutingTierName,
		
		RTC_ConnId, 
		RTC_ConnUid,
		RTC_Weight,
		RTC_Active)
	SELECT
		'v1_' + sa.StandardRouteIdName as RP_Name, 'Synced from Rounting v1' as RP_Description, --NULL AS RP_CreatedBy, SYSUTCDATETIME() AS RP_CreatedAt,
		'v1_' + sa.StandardRouteIdName as PP_Name, 'Synced from Rounting v1' as PP_Description, --NULL AS RP_CreatedBy, SYSUTCDATETIME() AS RP_CreatedAt,
		ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) AS RPC_Country, op.OperatorId AS RPC_OperatorId,
		NULL AS RPC_RoutingGroupId, 
		'EUR' AS RPC_CostCurrency, NULL AS RPC_CostCalculated,
		ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) AS PPC_Country, op.OperatorId AS PPC_OperatorId, 
		'EUR' AS PPC_Currency, CAST(p.Price as real) AS PPC_Price, NULL AS PPC_PricingFormulaId,
		'Plan/v1_' + sa.StandardRouteIdName + '/' + ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') AS RG_RoutingGroupName, 
		--NULL AS RPC_CreatedBy, SYSUTCDATETIME() AS RPC_CreatedAt, NULL AS RPC_UpdatedBy, SYSUTCDATETIME() AS RPC_UpdatedAt,
		1 AS RGT_Level,
		'Plan/v1_' + sa.StandardRouteIdName + '/' + ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') + '/L1' AS RT_RoutingTierName, 
		p.RouteId AS RTC_ConnId, cc.RouteUid AS RTC_ConnUid, 1 AS RTC_Weight, p.Active AS RTC_Active
	FROM dbo.StandardAccount sa
		INNER JOIN dbo.PlanRouting p ON p.SubAccountId = sa.SubAccountId AND p.AccountId = sa.AccountId /* it's only to remove case when SubAccountId='*'  */
		LEFT JOIN mno.Operator op ON TRY_PARSE(p.Operator as int) = op.OperatorId 
		LEFT JOIN mno.Country c ON p.Prefix = c.DialCode + '%' AND TRY_PARSE(p.Operator as int) IS NULL
		INNER JOIN dbo.CarrierConnections cc ON p.RouteId = cc.RouteId
	WHERE p.Active = 1 AND LEN(p.Prefix) <= 4
		AND ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) IS NOT NULL
		--AND sa.SubAccountId <> '*'
		--AND sa.StandardRouteIdName = 'wholesale_lc'

	PRINT dbo.Log_ROWCOUNT ('Populated temp flat table ##RoutingSync')
	IF (SELECT COUNT(1) FROM ##RoutingSync) < 1000
		THROW 51000, 'Error in sync Routing Plans', 1;

	--INSERT INTO ##RoutingSync (
	--	RP_Name,
	--	RP_Description,
	--	PP_Name,
	--	PP_Description,

	--	RPC_Country,
	--	RPC_OperatorId,
	--	RPC_RoutingGroupId,
	--	RPC_CostCurrency,
	--	RPC_CostCalculated,
		
	--	PPC_Country,
	--	PPC_OperatorId,
	--	PPC_Currency,
	--	PPC_Price,
	--	PPC_PricingFormulaId,
		
	--	RG_RoutingGroupName,
	--	RGT_Level,
	--	RT_RoutingTierName,
		
	--	RTC_ConnId, 
	--	RTC_ConnUid,
	--	RTC_Weight,
	--	RTC_Active)
	--SELECT
	--	'v2 HQ Routing' as RP_Name, 'Imported from KDB' as RP_Description,
	--	'v2 HQ Routing' as PP_Name, 'Imported from KDB' as PP_Description,
	--	op.CountryISO2alpha AS RPC_Country, op.OperatorId AS RPC_OperatorId,
	--	NULL AS RPC_RoutingGroupId, 
	--	'EUR' AS RPC_CostCurrency, supl.CostEUR AS RPC_CostCalculated,
	--	op.CountryISO2alpha AS PPC_Country, op.OperatorId AS PPC_OperatorId, 
	--	'EUR' AS PPC_Currency, supl.CostEUR AS PPC_Price, NULL AS PPC_PricingFormulaId,
	--	'Plan/v2 HQ Routing/' + op.CountryISO2alpha + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') AS RG_RoutingGroupName, 
	--	kdb.Ranking+1 AS RGT_Level,
	--	'Plan/v2 HQ Routing/' + op.CountryISO2alpha + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') + '/L' + CAST(kdb.Ranking+1 as varchar(2)) AS RT_RoutingTierName, 
	--	kdb.RouteId AS RTC_ConnId, cc.RouteUid AS RTC_ConnUid, 1 AS RTC_Weight, kdb.IsActiveRoute AS RTC_Active
	--FROM [rt].[RoutingView_Operator] kdb
	--	--INNER JOIN dbo.PlanRouting p ON p.SubAccountId = sa.SubAccountId AND p.AccountId = sa.AccountId /* it's only to remove case when SubAccountId='*'  */
	--	INNER JOIN mno.Operator op ON kdb.OperatorId = op.OperatorId 
	--	--LEFT JOIN mno.Country c ON p.Prefix = c.DialCode + '%' AND TRY_PARSE(p.Operator as int) IS NULL
	--	INNER JOIN dbo.CarrierConnections cc ON kdb.RouteId = cc.RouteId
	--	LEFT JOIN rt.vwSupplierCostCoverage_Active supl ON supl.ConnUid = cc.RouteUid AND supl.OperatorId = kdb.OperatorId
	--WHERE kdb.Ranking is not null and kdb.IsActiveRoute = 1
		
	--PRINT dbo.Log_ROWCOUNT ('Populated temp flat table ##RoutingSync based on KDB')

	--------------------------
	-- RoutingPlan
	--------------------------
	INSERT INTO rt.RoutingPlan (RoutingPlanName, Description)
	SELECT DISTINCT rs.RP_Name, rs.RP_Description
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingPlan rp ON rs.RP_Name = rp.RoutingPlanName
	WHERE rp.RoutingPlanId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('New RoutingPlans added')

	UPDATE rs SET RP_Id = rp.RoutingPlanId
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingPlan rp ON rs.RP_Name = rp.RoutingPlanName
	
	--------------------------
	-- PricingPlan
	--------------------------
	INSERT INTO rt.PricingPlan (PricingPlanName, Description, OwnerId)
	SELECT DISTINCT rs.PP_Name, rs.PP_Description, 9 AS OwnerId /* Anton */
	FROM ##RoutingSync rs
		LEFT JOIN rt.PricingPlan pp ON rs.PP_Name = pp.PricingPlanName
	WHERE pp.PricingPlanId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('New PricingPlans added')

	UPDATE rs SET PP_Id = pp.PricingPlanId
	FROM ##RoutingSync rs
		INNER JOIN rt.PricingPlan pp ON rs.PP_Name = pp.PricingPlanName

	--------------------------
	-- RoutingGroup
	--------------------------
	INSERT INTO rt.RoutingGroup (RoutingGroupName)
	SELECT DISTINCT rs.RG_RoutingGroupName
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingGroup rg ON rs.RG_RoutingGroupName = rg.RoutingGroupName
	WHERE rg.RoutingGroupId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('New RoutingGroups added')

	UPDATE rs SET RG_Id = rg.RoutingGroupId, RPC_RoutingGroupId = rg.RoutingGroupId
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingGroup rg ON rs.RG_RoutingGroupName = rg.RoutingGroupName
	
	--------------------------
	-- PricingFormula
	--------------------------
	--INSERT INTO rt.RoutingGroup (RoutingGroup)
	--SELECT DISTINCT rs.RG_RoutingGroupName
	--FROM ##RoutingSync rs
	--	LEFT JOIN rt.PricingFormula pf ON rs.PF = pf.PricingFormula
	--WHERE rg.RoutingGroupId IS NULL
	
	--PRINT dbo.Log_ROWCOUNT ('New PricingFormulas added')

	--UPDATE rs SET RG_Id = rg.RoutingGroupId, RPC_RoutingGroupId = rg.RoutingGroupId
	--FROM ##RoutingSync rs
	--	INNER JOIN rt.PricingFormula pf ON rs.
	 
	--------------------------
	-- RoutingPlanCoverage
	--------------------------
	INSERT INTO rt.RoutingPlanCoverage (RoutingPlanId, Country, OperatorId, RoutingGroupId, CostCurrency, CostCalculated)
	SELECT DISTINCT rs.RP_Id, rs.RPC_Country, rs.RPC_OperatorId, rs.RPC_RoutingGroupId, rs.RPC_CostCurrency, AVG(rs.RPC_CostCalculated) OVER(PARTITION BY rs.RPC_OperatorId) AS RPC_CostCalculated
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingPlanCoverage rpc ON rs.RP_Id = rpc.RoutingPlanId AND rs.RPC_Country = rpc.Country AND ISNULL(rs.RPC_OperatorId,0) = ISNULL(rpc.OperatorId,0)
	WHERE rpc.RoutingPlanCoverageId IS NULL AND rs.RGT_Level = 1
	
	PRINT dbo.Log_ROWCOUNT ('RoutingPlanCoverage - inserts')

	UPDATE rs SET RPC_Id = rpc.RoutingPlanCoverageId
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingPlanCoverage rpc ON rs.RP_Id = rpc.RoutingPlanId AND rs.RPC_Country = rpc.Country AND ISNULL(rs.RPC_OperatorId,0) = ISNULL(rpc.OperatorId,0)
	
	UPDATE rpc 
	SET RoutingGroupId = rs.RPC_RoutingGroupId, CostCurrency = rs.RPC_CostCurrency, CostCalculated = rs.RPC_CostCalculated,
		UpdatedAt = SYSUTCDATETIME()
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingPlanCoverage rpc ON rs.RP_Id = rpc.RoutingPlanId AND rs.RPC_Country = rpc.Country AND ISNULL(rs.RPC_OperatorId,0) = ISNULL(rpc.OperatorId,0) AND rs.RGT_Level = 1
	WHERE NOT (rpc.RoutingGroupId = rs.RPC_RoutingGroupId AND rpc.CostCurrency = rs.RPC_CostCurrency AND rpc.CostCalculated = rs.RPC_CostCalculated)
	PRINT dbo.Log_ROWCOUNT ('RoutingPlanCoverage - updates')

	--delete
	UPDATE rpc SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	--SELECT *
	FROM ##RoutingSync rs
		RIGHT JOIN rt.RoutingPlanCoverage rpc ON rs.RP_Id = rpc.RoutingPlanId AND rs.RPC_Country = rpc.Country AND ISNULL(rs.RPC_OperatorId,0) = ISNULL(rpc.OperatorId,0)
	WHERE rs.RPC_Id IS NULL AND rpc.RoutingPlanId IN (SELECT DISTINCT RP_Id FROM ##RoutingSync)
	PRINT dbo.Log_ROWCOUNT ('RoutingPlanCoverage - deletes')

	--------------------------
	-- PricingPlanCoverage
	--------------------------
	INSERT INTO rt.PricingPlanCoverage (PricingPlanId, Country, OperatorId, Currency, PricingFormulaId, Price, MarginRate, CompanyCurrency, CompanyPrice)
	SELECT rs.PP_Id, rs.PPC_Country, rs.PPC_OperatorId, rs.PPC_Currency, rs.PPC_PricingFormulaId, null as PPC_Price, rs.PPC_MarginRate, rs.PPC_Currency, null PPC_Price
	FROM ##RoutingSync rs
		LEFT JOIN rt.PricingPlanCoverage ppc ON rs.PP_Id = ppc.PricingPlanId AND rs.PPC_Country = ppc.Country AND ISNULL(rs.PPC_OperatorId,0) = ISNULL(ppc.OperatorId,0)
	WHERE ppc.PricingPlanCoverageId IS NULL

	PRINT dbo.Log_ROWCOUNT ('PricingPlanCoverage - inserts')

	UPDATE rs SET PPC_Id = PPC.PricingPlanCoverageId
	FROM ##RoutingSync rs
		INNER JOIN rt.PricingPlanCoverage PPC ON rs.PP_Id = PPC.PricingPlanId AND rs.PPC_Country = PPC.Country AND ISNULL(rs.PPC_OperatorId,0) = ISNULL(PPC.OperatorId,0)
	
	UPDATE ppc SET Currency = rs.PPC_Currency, PricingFormulaId = rs.PPC_PricingFormulaId, Price = rs.PPC_Price, UpdatedAt = SYSUTCDATETIME()
	FROM ##RoutingSync rs
		INNER JOIN rt.PricingPlanCoverage PPC ON rs.PP_Id = PPC.PricingPlanId AND rs.PPC_Country = PPC.Country AND ISNULL(rs.PPC_OperatorId,0) = ISNULL(PPC.OperatorId,0)
	WHERE NOT (ppc.Currency = rs.PPC_Currency AND ppc.PricingFormulaId = rs.PPC_PricingFormulaId AND ppc.Price = rs.PPC_Price)
	PRINT dbo.Log_ROWCOUNT ('PricingPlanCoverage - updates')

	--delete
	UPDATE ppc SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	FROM ##RoutingSync rs
		RIGHT JOIN rt.PricingPlanCoverage ppc ON rs.PP_Id = ppc.PricingPlanId AND rs.PPC_Country = ppc.Country AND ISNULL(rs.PPC_OperatorId,0) = ISNULL(ppc.OperatorId,0)
	WHERE rs.PPC_Id IS NULL AND ppc.PricingPlanId IN (SELECT DISTINCT PP_Id FROM ##RoutingSync)
	PRINT dbo.Log_ROWCOUNT ('PricingPlanCoverage - deletes')

	--------------------------
	-- RoutingTier
	--------------------------
	INSERT INTO rt.RoutingTier (RoutingTierName, ConnSummary, TierLevel, RoutingGroupId)
	SELECT DISTINCT rs.RT_RoutingTierName, --rs.RTC_ConnId + '[100%]',
		stuff((select ', ' + rs2.RTC_ConnId from ##RoutingSync rs2
        where rs2.RT_RoutingTierName = rs.RT_RoutingTierName
        for xml path('')), 1, 2, '') AS ConnSummary,
		1, rs.RG_Id
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingTier rt ON rs.RT_RoutingTierName = rt.RoutingTierName
	WHERE rt.RoutingTierId IS NULL
	--	and rs.RPC_OperatorId = 234020

	PRINT dbo.Log_ROWCOUNT ('New RoutingTiers added')

	UPDATE rs SET RT_Id = rt.RoutingTierId
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingTier rt ON rs.RT_RoutingTierName = rt.RoutingTierName

	UPDATE rt SET RoutingTierName = rs.RT_RoutingTierName, ConnSummary = RTC_ConnId, UpdatedAt = SYSUTCDATETIME(), Deleted = 0
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingTier rt ON rs.RT_Id = rt.RoutingTierId
	WHERE NOT (rs.RT_RoutingTierName = rt.RoutingTierName AND rt.ConnSummary = rs.RTC_ConnId AND rt.Deleted = 0)
	PRINT dbo.Log_ROWCOUNT ('RoutingTier - updates')
	--------------------------
	-- RoutingTierConn
	--------------------------
	INSERT INTO rt.RoutingTierConn (RoutingTierId, ConnId, ConnUid, Weight, Active)
	SELECT DISTINCT rs.RT_Id, rs.RTC_ConnId, rs.RTC_ConnUid, rs.RTC_Weight, rs.RTC_Active
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingTierConn rtc ON rs.RT_Id = rtc.RoutingTierId AND rtc.Deleted = 0 --AND rs.RTC_ConnId = rtc.ConnId
	WHERE rtc.TierEntryId IS NULL
	--	AND rs.RPC_OperatorId = 525001

	PRINT dbo.Log_ROWCOUNT ('New RoutingTierConns added')

	UPDATE rtc SET Active = rs.RTC_Active
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingTierConn rtc ON rs.RT_Id = rtc.RoutingTierId  AND rs.RTC_ConnUid = rtc.ConnUid
	WHERE NOT (rs.RTC_Active = rtc.Active AND rs.RTC_ConnUid = rtc.ConnUid)
	PRINT dbo.Log_ROWCOUNT ('RoutingTierConns - updates')

	select * from rt.vwRoutingPlanCoverageAllConn where RoutingPlanId = 9 and OperatorId = 525001
	--------------------
	------
	-- RoutingGroupTier
	--------------------------
	INSERT INTO rt.RoutingGroupTier(RoutingGroupId, [Level], RoutingTierId)
	SELECT DISTINCT rs.RG_Id, rs.RGT_Level, rs.RT_Id
	FROM ##RoutingSync rs
		LEFT JOIN rt.RoutingGroupTier rgt ON rs.RG_Id = rgt.RoutingGroupId AND rs.RGT_Level = rgt.[Level]
	WHERE rgt.RoutingGroupTierId IS NULL
	PRINT dbo.Log_ROWCOUNT ('RoutingGroupTier - inserts')

	UPDATE rgt SET RoutingTierId = rs.RT_Id
	--SELECT *
	FROM ##RoutingSync rs
		INNER JOIN rt.RoutingGroupTier rgt ON rs.RG_Id = rgt.RoutingGroupId AND rs.RGT_Level = rgt.[Level]
	WHERE NOT (rs.RT_Id = rgt.RoutingTierId)
	PRINT dbo.Log_ROWCOUNT ('RoutingGroupTier - updates')

	--------------------------
	--------------------------
	--SELECT rpc.RoutingPlanCoverageId, AVG(scc.CostEUR)
	--FROM rt.RoutingPlanCoverage rpc
	--	INNER JOIN rt.RoutingGroupTier rgt ON rpc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Level = 1
	--	INNER JOIN rt.RoutingTierConn rtc ON rgt.RoutingTierId = rtc.RoutingTierId
	--	INNER JOIN rt.SupplierCostCoverage scc ON scc.Country = rpc.Country AND scc.OperatorId = rpc.OperatorId
	--WHERE rtc.Deleted = 0 AND rgt.Deleted = 0
	--GROUP BY rpc.RoutingPlanCoverageId

	-- update CostCalculated in RoutingPlanCoverage
	UPDATE rpc SET CostCalculated = rtc.CostCalculated
	FROM rt.RoutingTier rt
		INNER JOIN rt.RoutingGroupTier rgt ON rt.RoutingTierId = rgt.RoutingTierId AND rgt.Level = 1 AND rgt.Deleted = 0 AND rt.Deleted = 0
		INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rgt.RoutingGroupId
		INNER JOIN (
			SELECT rtc.RoutingTierId, scc.Country, scc.OperatorId, SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight) AS CostCalculated
			FROM rt.RoutingTierConn rtc
				INNER JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid /*AND scc.Country = @Country AND ISNULL(scc.OperatorId, 0) = ISNULL(@OperatorId, 0)*/
			WHERE rtc.Deleted = 0
			GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId
		) rtc ON rt.RoutingTierId = rtc.RoutingTierId AND rpc.Country = rtc.Country AND ISNULL(rpc.OperatorId, 0) = ISNULL(rtc.OperatorId, 0)
	
	PRINT dbo.Log_ROWCOUNT ('Update CostCalculated for RoutingPlanCoverage')

	-- update CostCalculated AND Price based on Margin in RoutingCustom
	UPDATE rpc SET CostCalculated = rtc.CostCalculated, Price = IIF(MarginRate IS NOT NULL, 100 * rtc.CostCalculated / (100 - MarginRate), Price)
	FROM rt.RoutingTier rt
		INNER JOIN rt.RoutingGroupTier rgt ON rt.RoutingTierId = rgt.RoutingTierId AND rgt.Level = 1 AND rgt.Deleted = 0 AND rt.Deleted = 0
		INNER JOIN rt.RoutingCustom rpc ON rpc.RoutingGroupId = rgt.RoutingGroupId
		INNER JOIN (
			SELECT rtc.RoutingTierId, scc.Country, scc.OperatorId, SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight) AS CostCalculated
			FROM rt.RoutingTierConn rtc
				INNER JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid /*AND scc.Country = @Country AND ISNULL(scc.OperatorId, 0) = ISNULL(@OperatorId, 0)*/
			WHERE rtc.Deleted = 0
			GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId
		) rtc ON rt.RoutingTierId = rtc.RoutingTierId AND rpc.Country = rtc.Country AND ISNULL(rpc.OperatorId, 0) = ISNULL(rtc.OperatorId, 0)
	PRINT dbo.Log_ROWCOUNT ('Update CostCalculated for RoutingCustom')

	--------------------------
	-- SubAccount_Default
	--------------------------
	--select * from rt.SubAccount_Default
	MERGE rt.SubAccount_Default AS t
	USING (
		SELECT a.SubAccountUid, rp.RoutingPlanId, pp.PricingPlanId
		FROM dbo.Account a
			INNER JOIN rt.RoutingPlan rp ON 'v1_' + a.StandardRouteId = rp.RoutingPlanName
			INNER JOIN rt.PricingPlan pp ON 'v1_' + a.StandardRouteId = pp.PricingPlanName
	) AS s --(SubAccountUid, RoutingPlanId, PricingPlanId)
	ON (t.SubAccountUid = s.SubAccountUid)
	WHEN MATCHED AND (t.RoutingPlanId_Default <> s.RoutingPlanId OR t.PricingPlanId_Default <> s.PricingPlanId)
		THEN UPDATE SET 
			t.RoutingPlanId_Default = s.RoutingPlanId,
			t.PricingPlanId_Default = s.PricingPlanId
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (SubAccountUid, RoutingPlanId_Default, PricingPlanId_Default)
			VALUES (s.SubAccountUid, s.RoutingPlanId, s.PricingPlanId)
	WHEN NOT MATCHED BY SOURCE
		THEN UPDATE SET Deleted = 1;
 
	PRINT dbo.Log_ROWCOUNT ('SubAccount_Default - merge')

	---------
	If(OBJECT_ID('tempdb..#RoutingCustomSync') IS NOT NULL) DROP TABLE #RoutingCustomSync

	CREATE TABLE #RoutingCustomSync (
		RC_Id int NULL,
		RC_SubAccountUid int NOT NULL,
		RC_Country char(2) NULL,
		RC_OperatorId int NULL,
		RC_RoutingGroupId int NULL,
		RC_PriceCurrency varchar(3) NOT NULL,
		RC_Price real NULL,
		RC_PricingFormulaId int NULL,
		
		RG_Id int NULL,
		RG_RoutingGroupName varchar(100) NULL,
		RGT_Level int NOT NULL,
		
		RT_Id int NULL,
		RT_RoutingTierName varchar(100) NULL,
		--RTC_Id int NULL,
		RTC_ConnId varchar(50) NOT NULL,
		RTC_ConnUid int NOT NULL,
		RTC_Weight int NOT NULL,
		RTC_Active bit NOT NULL
	)

	INSERT INTO #RoutingCustomSync (
		RC_SubAccountUid,
		RC_Country,
		RC_OperatorId,
		--RC_RoutingGroupId int NULL,
		RC_PriceCurrency,
		RC_Price,
		RC_PricingFormulaId,
		RG_RoutingGroupName,
		RGT_Level,
		RT_RoutingTierName,
		RTC_ConnId,
		RTC_ConnUid,
		RTC_Weight,
		RTC_Active)
	SELECT 
		a.SubAccountUid AS RC_SubAccountUid,
		ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) AS RC_Country, op.OperatorId AS RC_OperatorId,
		--NULL AS RC_RoutingGroupId, 
		'EUR' AS RC_PriceCurrency, CAST(p.Price as real) AS RC_Price, NULL AS RC_PricingFormulaId,
		'Custom/' + a.SubAccountId + '/' + ISNULL(op.CountryISO2alpha, ISNULL(c.CountryISO2alpha, 'ALL')) + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') AS RG_RoutingGroupName, 
		1 AS RGT_Level,
		'Custom/' + a.SubAccountId + '/' + ISNULL(op.CountryISO2alpha, ISNULL(c.CountryISO2alpha, 'ALL')) + '/' + ISNULL(CAST(op.OperatorId as varchar(6)), 'DEF') + '/L1' AS RT_RoutingTierName, 
		p.RouteId AS RTC_ConnId, cc.RouteUid AS RTC_ConnUid, 1 AS RTC_Weight, p.Active AS RTC_Active
	-- SELECT *
	FROM dbo.Account a
		INNER JOIN dbo.PlanRouting p ON p.SubAccountId = a.SubAccountId AND p.AccountId = a.AccountId /* it's only to remove case when SubAccountId='*'  */
		LEFT JOIN mno.Operator op ON TRY_PARSE(p.Operator as int) = op.OperatorId 
		LEFT JOIN mno.Country c ON p.Prefix = c.DialCode + '%' AND TRY_PARSE(p.Operator as int) IS NULL
		INNER JOIN dbo.CarrierConnections cc ON p.RouteId = cc.RouteId
	WHERE p.Active = 1 AND LEN(p.Prefix) <= 4 /* only country code prefix supported, no more */
		AND (op.OperatorId IS NOT NULL OR c.CountryISO2alpha IS NOT NULL)
		--AND p.SubAccountId NOT IN (SELECT SubAccountId FROM dbo.StandardAccount)

	IF (SELECT COUNT(1) FROM #RoutingCustomSync) < 1000
		THROW 51000, 'Error in sync Custom Routing', 1;
	
	--SELECT * FROM #RoutingCustomSync
	--select * from rt.vwRoutingPlanCoverage
	--select * from rt.vwRoutingTierConnMap

	--------------------------
	-- RoutingGroup
	--------------------------
	INSERT INTO rt.RoutingGroup (RoutingGroupName)
	SELECT DISTINCT rs.RG_RoutingGroupName
	FROM #RoutingCustomSync rs
		LEFT JOIN rt.RoutingGroup rg ON rs.RG_RoutingGroupName = rg.RoutingGroupName
	WHERE rg.RoutingGroupId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('RoutingGroups for custom - inserts')

	UPDATE rc SET RG_Id = rg.RoutingGroupId, RC_RoutingGroupId = rg.RoutingGroupId
	FROM #RoutingCustomSync rc
		INNER JOIN rt.RoutingGroup rg ON rc.RG_RoutingGroupName = rg.RoutingGroupName
	
	--------------------------
	-- RoutingTier
	--------------------------
	INSERT INTO rt.RoutingTier (RoutingTierName)
	SELECT DISTINCT rs.RT_RoutingTierName
	FROM #RoutingCustomSync rs
		LEFT JOIN rt.RoutingTier rt ON rs.RT_RoutingTierName = rt.RoutingTierName
	WHERE rt.RoutingTierId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('RoutingTiers for custom - inserts')

	UPDATE rs SET RT_Id = rt.RoutingTierId
	FROM #RoutingCustomSync rs
		INNER JOIN rt.RoutingTier rt ON rs.RT_RoutingTierName = rt.RoutingTierName

	--------------------------
	-- RoutingTierConn
	--------------------------
	INSERT INTO rt.RoutingTierConn (RoutingTierId, ConnId, ConnUid, Weight, Active)
	SELECT DISTINCT rs.RT_Id, rs.RTC_ConnId, rs.RTC_ConnUid, rs.RTC_Weight, rs.RTC_Active
	FROM #RoutingCustomSync rs
		LEFT JOIN rt.RoutingTierConn rtc ON rs.RT_Id = rtc.RoutingTierId --AND rs.RTC_ConnId = rtc.ConnId
	WHERE rtc.TierEntryId IS NULL
	
	PRINT dbo.Log_ROWCOUNT ('RoutingTierConns for custom - inserts')

	--------------------------
	-- RoutingGroupTier
	--------------------------
	INSERT INTO rt.RoutingGroupTier(RoutingGroupId, [Level], RoutingTierId)
	SELECT DISTINCT rs.RG_Id, rs.RGT_Level, rs.RT_Id
	FROM #RoutingCustomSync rs
		LEFT JOIN rt.RoutingGroupTier rgt ON rs.RG_Id = rgt.RoutingGroupId AND rs.RGT_Level = rgt.[Level]
	WHERE rgt.RoutingGroupTierId IS NULL

	PRINT dbo.Log_ROWCOUNT ('RoutingGroupTier for custom - inserts')

	--------------------------
	-- RoutingCustom
	--------------------------
	MERGE rt.RoutingCustom AS t
	USING (
		SELECT * FROM #RoutingCustomSync
	) AS s
	ON (t.SubAccountUid = s.RC_SubAccountUid 
		AND ISNULL(t.Country,'ALL') = ISNULL(s.RC_Country,'ALL')
		AND ISNULL(t.OperatorId,0) = ISNULL(s.RC_OperatorId,0)
		)
	WHEN MATCHED --AND (t.RoutingPlanId_Default <> s.RoutingPlanId OR t.PricingPlanId_Default <> s.PricingPlanId)
		THEN UPDATE SET 
			t.RoutingGroupId	= s.RC_RoutingGroupId,
			t.PriceCurrency		= s.RC_PriceCurrency,
			t.PricingFormulaId	= s.RC_PricingFormulaId,
			t.Price				= s.RC_Price
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (SubAccountUid, Country, OperatorId, RoutingGroupId, PriceCurrency, CompanyCurrency, PricingFormulaId, Price, CompanyPrice)
			VALUES (s.RC_SubAccountUid, s.RC_Country, s.RC_OperatorId, s.RC_RoutingGroupId, s.RC_PriceCurrency, s.RC_PriceCurrency, s.RC_PricingFormulaId, s.RC_Price, s.RC_Price)
	WHEN NOT MATCHED BY SOURCE
		THEN UPDATE SET Deleted = 1;
 
	PRINT dbo.Log_ROWCOUNT ('RoutingCustom - merge')

	--------------------------
	-- Supplier Cost Coverage
	--------------------------
	MERGE rt.SupplierCostCoverage AS target
    USING (
		/* cost per country + operatorId + routeId */
		SELECT o.CountryISO2alpha as Country, o.OperatorId, cc.RouteId, cc.RouteUid, 
			c.Cost as CostLocal, 'EUR' as [CostLocalCurrency], c.Cost as CostEUR,
			'2017/01/01' AS EffectiveFrom
		FROM dbo.CPCost c
			INNER JOIN mno.Operator o ON o.OperatorId = CAST(c.Operator as int)
			INNER JOIN dbo.CarrierConnections cc ON cc.RouteId = c.RouteId
		WHERE c.Active = 1
		UNION
		/* cost per country + routeid + undefined operator */
		SELECT o.CountryISO2alpha as Country, NULL AS OperatorId, cc.RouteId, cc.RouteUid, 
			MAX(c.Cost) as CostLocal, 'EUR' as [CostLocalCurrency], MAX(c.Cost) as CostEUR,
			'2017/01/01' AS EffectiveFrom
		FROM dbo.CPCost c
			INNER JOIN mno.Operator o ON o.OperatorId = CAST(c.Operator as int)
			INNER JOIN dbo.CarrierConnections cc ON cc.RouteId = c.RouteId
		WHERE c.Active = 1
		GROUP BY o.CountryISO2alpha, cc.RouteId, cc.RouteUid
	) AS source
    ON (target.Country = source.Country AND target.RouteUid = source.RouteUid AND ISNULL(target.OperatorId,0) = ISNULL(source.OperatorId,0))
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Country, OperatorId, RouteId, RouteUid, 
			CostLocal, CostLocalCurrency, CostEUR,
			EffectiveFrom, UpdatedAt, Deleted) 
		VALUES (source.Country, source.OperatorId, source.RouteId, source.RouteUid, 
			source.CostLocal, source.CostLocalCurrency, source.CostEUR,
			source.EffectiveFrom, SYSUTCDATETIME(), 0)
	WHEN NOT MATCHED BY SOURCE THEN
		UPDATE SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHEN MATCHED AND (target.CostEUR <> source.CostEUR) THEN
		UPDATE SET CostEUR = source.CostEUR, CostLocalCurrency = source.CostLocalCurrency, CostLocal = source.CostLocal,
			RouteId = source.RouteId,
			Deleted = 0, UpdatedAt = SYSUTCDATETIME();

	PRINT [dbo].[Log_ROWCOUNT] ('rt.SupplierCostCoverage - merge')

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Finished sync'
END


