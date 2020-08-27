-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-28
-- Description:	Update next-generation dictionaries for MessageSphere
-- =============================================
CREATE PROCEDURE [rt].[job_UpdateFromMessageSphere_v1]
AS
BEGIN
	
	/*** SYNC acc.Account ***/

	-- temp workaround when 2 tables exists
	DELETE TOP (1) FROM sa2
	--SELECT *
	FROM dbo.Account sa1
		INNER JOIN ms.SubAccount sa2 ON sa1.SubAccountId = sa2.SubAccountId
	WHERE sa1.SubAccountUid <> sa2.SubAccountUid AND sa2.CreatedAt > DATEADD(HOUR, -2, GETUTCDATE()) 

	MERGE ms.SubAccount AS target
	USING (
			SELECT sa.SubAccountUid, sa.SubAccountId, a.AccountUid, sa.Active & (1-sa.Deleted) AS Active, ISNULL(sa.Date, SYSUTCDATETIME()) AS CreatedAt, sa.UpdatedAt, sa.PriceNotifiedAt
			FROM dbo.Account sa
				INNER JOIN cp.Account a ON a.AccountId = sa.AccountId
		) AS source (SubAccountUid, SubAccountId, AccountUid, Active, CreatedAt, UpdatedAt, PriceNotifiedAt)
	ON (target.SubAccountUid = source.SubAccountUid)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (SubAccountUid, SubAccountId, AccountUid, Active, CreatedAt, UpdatedAt, PriceNotifiedAt, Product_SMS, Product_CA) 
		VALUES (source.SubAccountUid, source.SubAccountId, source.AccountUid, source.Active, source.CreatedAt, source.UpdatedAt, source.PriceNotifiedAt, 1 /* SMS enabled by default */, 0 /* CA set later */)
	WHEN NOT MATCHED BY SOURCE AND target.Active = 1 THEN
		UPDATE SET Active = 0
	WHEN MATCHED AND (target.UpdatedAt < source.UpdatedAt) THEN
		UPDATE SET 
			SubAccountId = source.SubAccountId, 
			AccountUid = source.AccountUid, 
			Active = source.Active, 
			UpdatedAt = source.UpdatedAt, 
			PriceNotifiedAt = source.PriceNotifiedAt;

	/*
	-- troubleshooting of SubAccountUid conflict
	--UPDATE sa SET sa.SubAccountUid = a.SubAccountUid, sa.Active = a.Active
	SELECT * 
	FROM ms.SubAccount sa 
		INNER JOIN dbo.Account a ON sa.SubAccountId = a.SubAccountId
	WHERE sa.SubAccountUid <> a.SubAccountUid
	*/

	PRINT [dbo].[Log_ROWCOUNT] ('Sync table ms.SubAccount')

	
	-- SubAccount - Activate Product_VO
	UPDATE sa SET Product_VO = (1 - vo.Deleted)
	--select *
	FROM ms.SubAccount sa
		INNER JOIN [WC_VOICE].voice.SubAccount vo ON vo.SubAccountUid = sa.SubAccountUid
	WHERE sa.Product_VO <> (1 - vo.Deleted)
	PRINT [dbo].[Log_ROWCOUNT] ('ms.SubAccount - Activate Product_VO')


	-- Account - Set Product flags based on subaccounts
	UPDATE a SET
		Product_SMS = IIF(sa.Product_SMS_Cnt > 0, 1, 0),
		Product_CA = IIF(sa.Product_CA_Cnt > 0, 1, 0),
		Product_VO = IIF(sa.Product_VO_Cnt > 0, 1, 0)
	--SELECT *
	FROM cp.Account a
		LEFT JOIN (
			SELECT 
				sa.AccountUid, 
				SUM(CAST(sa.Product_SMS & sa.Active AS tinyint)) AS Product_SMS_Cnt,
				SUM(CAST(sa.Product_CA  & sa.Active AS tinyint)) AS Product_CA_Cnt,
				SUM(CAST(sa.Product_VO  & sa.Active AS tinyint)) AS Product_VO_Cnt,
				MAX(sa.UpdatedAt) AS LastUpdatedAt
			FROM ms.SubAccount sa
			GROUP BY sa.AccountUid
		) sa ON a.AccountUid = sa.AccountUid
		--LEFT JOIN (
		--	SELECT st.AccountUid, SUM(st.SmsCountTotal) SmsCountTotal, SUM(st.SmsCountRejected) SmsCountRejected
		--	FROM sms.StatSmsLogDaily st
		--	WHERE st.Date > '2019-12-01'
		--	GROUP BY st.AccountUid) st ON st.AccountUid = a.AccountUid
	WHERE 
		(a.Product_SMS = 1 AND ISNULL(sa.Product_SMS_Cnt,0) = 0 AND ISNULL(sa.LastUpdatedAt, '2019-01-01') < DATEADD(MONTH, -3, GETUTCDATE())) -- no SMS profiles on account anymore, that removed more than X months ago
		OR (a.Product_SMS = 0 AND sa.Product_SMS_Cnt > 0) -- SMS product added to account
		OR (a.Product_CA = 1 AND ISNULL(sa.Product_CA_Cnt,0) = 0 AND ISNULL(sa.LastUpdatedAt, '2019-01-01') < DATEADD(MONTH, -3, GETUTCDATE())) -- no CA profiles on account anymore, that removed more than X months ago
		OR (a.Product_CA = 0 AND sa.Product_CA_Cnt > 0) -- CA product added to account
		OR (a.Product_VO = 1 AND ISNULL(sa.Product_VO_Cnt,0) = 0 AND ISNULL(sa.LastUpdatedAt, '2019-01-01') < DATEADD(MONTH, -3, GETUTCDATE())) -- no VO profiles on account anymore, that removed more than X months ago
		OR (a.Product_VO = 0 AND sa.Product_VO_Cnt > 0) -- VO product added to account

	PRINT [dbo].[Log_ROWCOUNT] ('cp.Account - Set Product_SMS, Product_CA, Product_VO flags')

	-- Account - Activate Product_VI
	-- TODO: add logic of dropping flag too
	UPDATE a SET Product_VI = 1
	--select *
	FROM cp.Account a
		INNER JOIN [WC_VIDEO].vi.Tenant t ON t.AccountUid = a.AccountUid
	WHERE a.Product_VI = 0
	PRINT [dbo].[Log_ROWCOUNT] ('cp.Account - Activate Product_VI')

	/*** SYNC rt.Route ***/
    MERGE rt.Route AS target
    USING (SELECT RouteId FROM dbo.CarrierConnections) AS source (RouteId)
    ON (target.RouteId = source.RouteId)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (RouteId) VALUES (source.RouteId)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	PRINT [dbo].[Log_ROWCOUNT] ('Sync table rt.Route')

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

	/*
	manual fix of edge case, created by Ops 
	SELECT *
	FROM dbo.CarrierConnections AS cc
		INNER JOIN rt.SupplierConn sc ON cc.RouteId = sc.ConnId AND cc.RouteUid <> sc.ConnUid
	UPDATE rt.SupplierConn SET ConnId = ConnId + '-deleted' WHERE ConnUid = 115 AND Deleted = 1
	*/

	PRINT dbo.Log_ROWCOUNT ('rt.SupplierConn - merge')

	/*** SYNC mno.Operator ***/
 --   MERGE mno.Operator AS target
 --   USING (
	--		SELECT o.OperatorId, o.OperatorName, c.CountryISO2alpha
	--		FROM dbo.Operator o INNER JOIN mno.Country c ON c.CountryName = o.Country
	--	) AS source (OperatorId, OperatorName, CountryISO2alpha)
 --   ON (target.OperatorId = source.OperatorId)
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (OperatorId, CountryISO2alpha, OperatorName) VALUES (source.OperatorId, source.CountryISO2alpha, source.OperatorName)
	--WHEN MATCHED AND (target.OperatorName <> source.OperatorName OR target.CountryISO2alpha = source.CountryISO2alpha) THEN
	--	UPDATE SET OperatorName = source.OperatorName, CountryISO2alpha = source.CountryISO2alpha
	--WHEN NOT MATCHED BY SOURCE THEN
	--	DELETE;


	/*** SYNC acc.Account ***/
 --   MERGE acc.Account AS target
 --   USING (
	--		SELECT a.AccountId, a.SubAccountId, a.IsActive, a.StandardRouteId, a.StandardSubAccountId
	--		FROM [WC_SMS].ext.Account a
	--	) AS source (AccountId, SubAccountId, IsActive, StandardRouteId, StandardSubAccountId)
 --   ON (target.SubAccountId = source.SubAccountId)
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (AccountId, SubAccountId, IsActive, StandardRouteId, StandardSubAccountId) VALUES (source.AccountId, source.SubAccountId, source.IsActive, source.StandardRouteId, source.StandardSubAccountId)
	--WHEN NOT MATCHED BY SOURCE THEN
	--	UPDATE SET IsActive = 0
	--WHEN MATCHED AND (target.IsActive <> source.IsActive OR target.StandardSubAccountId <> source.StandardSubAccountId) THEN
	--	UPDATE SET IsActive = source.IsActive, StandardRouteId = source.StandardRouteId, StandardSubAccountId = source.StandardSubAccountId;

	/*** SYNC rt.RouteOperator ***/
    MERGE rt.RoutingView_Operator AS target
    USING (
		-- deprecated source table
		--SELECT CAST (c.Operator as int) AS OperatorId, CAST(RouteId AS VARCHAR(50)) AS RouteId, 'EUR' as Currency, Cost, Active 
		--FROM dbo.CPCost c
		--WHERE EXISTS (SELECT 1 FROM mno.Operator o WHERE o.OperatorId = CAST (c.Operator as int))
		--	AND EXISTS (SELECT 1 FROM rt.Route r WHERE r.RouteId = c.RouteId)
			
		SELECT DISTINCT c.OperatorId, c.ConnUid, 1 AS Active 
		--SELECT *
		FROM rt.vwSupplierCostCoverage_Active c
		WHERE
			c.SmsTypeId = 1
			AND EXISTS (SELECT 1 FROM mno.Operator o WHERE o.OperatorId = c.OperatorId)
	) AS source (OperatorId, ConnUid, IsActiveRoute)
    ON (target.RouteUid = source.ConnUid AND target.OperatorId = source.OperatorId)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (OperatorId, RouteUid, IsActiveRoute) 
		VALUES (source.OperatorId, source.ConnUid, source.IsActiveRoute)
	WHEN NOT MATCHED BY SOURCE AND target.IsActiveRoute = 1 THEN
		UPDATE SET IsActiveRoute = 0
	WHEN MATCHED AND (target.IsActiveRoute <> source.IsActiveRoute) THEN
		UPDATE SET IsActiveRoute = source.IsActiveRoute;

	PRINT [dbo].[Log_ROWCOUNT] ('Sync table rt.RoutingView_Operator')

	/*** SYNC rt.RoutingView_Customer ***/
	/*
	-- DEPRICATED
	MERGE rt.RoutingView_Customer AS target
    USING (
		SELECT AccountId, SubAccountId, Prefix,
			ISNULL(pc.CountryISO2alpha, oc.CountryISO2alpha) AS Country,
			pr.OperatorId, RouteId, 
			Active as IsActiveRoute, CAST(Priority as TINYINT) as Priority,
			'EUR' as Currency, Price, Cost, RoutingMode
		FROM 
			(SELECT AccountId, SubAccountId, 
				CASE WHEN Prefix IN ('none', '%') THEN NULL ELSE CAST(Prefix as VARCHAR(16)) END AS Prefix, RouteId, CAST(Price as real) AS Price, CAST(Cost as real) AS Cost, 
				CAST(Priority as TINYINT) as Priority, Active, 
				CASE WHEN Operator = 'none' THEN NULL ELSE CAST(Operator as int) END AS OperatorId,
				ISNULL(RoutingMode, 0) AS RoutingMode
			FROM dbo.PlanRouting
			WHERE /* exclude prefix as MSISDN */ LEN(Prefix) < 5 ) pr 
			--get country by Prefix
			LEFT JOIN mno.Country pc ON REPLACE(pr.Prefix, '%', '') = pc.DialCode
			--get country of OperatorId
			LEFT JOIN mno.Operator o ON (pr.OperatorId IS NOT NULL AND pr.OperatorId = o.OperatorId)
			LEFT JOIN mno.Country oc ON oc.CountryISO2alpha = o.CountryISO2alpha
		WHERE (pr.OperatorId IS NULL OR EXISTS (SELECT 1 FROM mno.Operator o WHERE o.OperatorId = pr.OperatorId))
			AND EXISTS (SELECT 1 FROM rt.Route r WHERE r.RouteId = pr.RouteId)

		) AS source (AccountId, SubAccountId, Prefix, Country, OperatorId, RouteId, IsActiveRoute, Priority, Currency, Price, Cost, RoutingMode)
    ON (target.AccountId = source.AccountId AND target.SubAccountId = source.SubAccountId 
		AND ISNULL(target.Prefix,'$$$') = ISNULL(source.Prefix,'$$$') 
		AND ISNULL(target.OperatorId,-999) = ISNULL(source.OperatorId,-999) 
		AND target.Country = source.Country
		AND target.RouteId = source.RouteId 
		AND target.IsActiveRoute = source.IsActiveRoute )
	WHEN MATCHED 
		AND EXISTS (
				SELECT source.IsActiveRoute, source.Priority, source.Price, source.Cost, source.RoutingMode
				EXCEPT
				SELECT target.IsActiveRoute, target.Priority, target.Price, target.Cost, target.RoutingMode
			)
		THEN
		UPDATE SET 
			IsActiveRoute = source.IsActiveRoute, 
			Priority = source.Priority, 
			Currency = source.Currency,
			Price = source.Price, 
			Cost = source.Cost, 
			RoutingMode = source.RoutingMode
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (AccountId, SubAccountId, Prefix, Country, OperatorId, RouteId, IsActiveRoute, Priority, Currency, Price, Cost, RoutingMode) 
		VALUES (source.AccountId, source.SubAccountId, source.Prefix, source.Country, source.OperatorId, source.RouteId, source.IsActiveRoute, source.Priority, source.Currency, source.Price, source.Cost, source.RoutingMode)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	PRINT [dbo].[Log_ROWCOUNT] ('Sync table rt.RoutingView_Customer');
	*/

	-- Update comment field in view from source table
	-- DEPRICATED
	/*
	UPDATE rt
	SET Comment = meta.InfoMessage
	FROM rt.RoutingView_Customer AS rt
		LEFT JOIN rt.RoutingMeta meta ON rt.SubAccountId = meta.SubAccountId AND rt.Country = meta.Country AND ISNULL(rt.OperatorId, -999) = ISNULL(meta.OperatorId, -999)
	WHERE ISNULL(rt.Comment,'') <> ISNULL(meta.InfoMessage,'')

	PRINT [dbo].[Log_ROWCOUNT] ('Update Comment column in rt.RoutingView_Customer from rt.RoutingMeta')
	*/
	
	--------------------------
	-- Supplier Cost Coverage
	--------------------------

	-- auto-update of cost for UNDEFINED operator (OperatorId=NULL -> set max cost of defined OepratorId within Country)
	MERGE rt.SupplierCostCoverage AS target
    USING (
		SELECT q.RouteUid, q.Country, q.SmsTypeId, q.CostLocalCurrency, q.CostLocal, q.CostEUR, q.Deleted /* only 0 value */
		FROM (
			SELECT c.RouteUid, c.Country, c.SmsTypeId, c.CostLocalCurrency, c.CostLocal, c.CostEUR, c.Deleted,
				ROW_NUMBER() OVER(PARTITION BY c.RouteUid, c.Country, c.SmsTypeId ORDER BY CostEUR DESC) AS OrderNum
			FROM rt.SupplierCostCoverage c
			WHERE c.Deleted = 0 AND c.OperatorId IS NOT NULL) q
		WHERE q.OrderNum = 1
	) AS source
    ON (target.Country = source.Country AND 
		target.RouteUid = source.RouteUid AND 
		target.SmsTypeId = source.SmsTypeId AND 
		target.OperatorId IS NULL)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Country, OperatorId, RouteUid, SmsTypeId,
			CostLocal, CostLocalCurrency, CostEUR,
			EffectiveFrom, CreatedAt, UpdatedAt, Deleted) 
		VALUES (source.Country, NULL, source.RouteUid, source.SmsTypeId,
			source.CostLocal, source.CostLocalCurrency, source.CostEUR,
			SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), source.Deleted)
	WHEN NOT MATCHED BY SOURCE AND target.Deleted = 0 AND target.OperatorId IS NULL THEN
		UPDATE SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHEN MATCHED AND (target.CostLocalCurrency <> source.CostLocalCurrency OR target.CostLocal <> source.CostLocal OR target.Deleted <> source.Deleted) THEN
		UPDATE SET 
			CostEUR = source.CostEUR, 
			CostLocalCurrency = source.CostLocalCurrency, 
			CostLocal = source.CostLocal,
			EffectiveFrom = SYSUTCDATETIME(),
			Deleted = source.Deleted, /* only 0 case */
			UpdatedAt = SYSUTCDATETIME();
	--OUTPUT			-- for troubleshooting only, doesn't work with active triggers on table :(
	--   $action,
	--   inserted.*,
	--   deleted.*;

	PRINT [dbo].[Log_ROWCOUNT] ('rt.SupplierCostCoverage - Auto-update of cost for undefied operator');

	--DECLARE @Now datetime = GETUTCDATE()
	/*
	MERGE rt.SupplierCostCoverage AS target
    USING (
		/* cost per country + operatorId + routeId */
		SELECT o.CountryISO2alpha as Country, o.OperatorId, cc.RouteId, cc.RouteUid, 
			c.Cost as CostLocal, 'EUR' as [CostLocalCurrency], c.Cost as CostEUR,
			'2017/01/01' AS EffectiveFrom, c.UpdatedAt,
			1 - c.Active AS Deleted
		FROM dbo.CPCost c
			INNER JOIN mno.Operator o ON o.OperatorId = CAST(c.Operator as int)
			INNER JOIN dbo.CarrierConnections cc ON cc.RouteId = c.RouteId
		--WHERE c.Active = 1
		UNION
		/* cost per country + routeid + undefined operator */
		SELECT o.CountryISO2alpha as Country, NULL AS OperatorId, cc.RouteId, cc.RouteUid, 
			MAX(c.Cost) as CostLocal, 'EUR' as [CostLocalCurrency], MAX(c.Cost) as CostEUR,
			'2017/01/01' AS EffectiveFrom, MAX(c.UpdatedAt) AS UpdatedAt,
			0 AS Deleted
		FROM dbo.CPCost c
			INNER JOIN mno.Operator o ON o.OperatorId = CAST(c.Operator as int)
			INNER JOIN dbo.CarrierConnections cc ON cc.RouteId = c.RouteId
		WHERE c.Active = 1
		GROUP BY o.CountryISO2alpha, cc.RouteId, cc.RouteUid
		UNION
		/* Full coverage for TrashMessage */
		SELECT o.CountryISO2alpha as Country, o.OperatorId, 
			cc.RouteId, cc.RouteUid, 
			0 as CostLocal, 'EUR' as [CostLocalCurrency], 0 as CostEUR,
			'2017/01/01' AS EffectiveFrom, '2018/01/01' AS UpdatedAt, 
			0 AS Deleted
		FROM mno.Operator o
			CROSS JOIN dbo.CarrierConnections cc
		WHERE cc.RouteId = 'TrashMessage'
	) AS source
    ON (target.Country = source.Country AND target.RouteUid = source.RouteUid AND ISNULL(target.OperatorId,0) = ISNULL(source.OperatorId,0))
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Country, OperatorId, RouteId, RouteUid, 
			CostLocal, CostLocalCurrency, CostEUR,
			EffectiveFrom, UpdatedAt, Deleted) 
		VALUES (source.Country, source.OperatorId, source.RouteId, source.RouteUid, 
			source.CostLocal, source.CostLocalCurrency, source.CostEUR,
			source.EffectiveFrom, source.UpdatedAt, source.Deleted)
	--WHEN NOT MATCHED BY SOURCE AND target.Deleted = 0 THEN
	--	UPDATE SET Deleted = 1, UpdatedAt = GETUTCDATE()
	WHEN MATCHED AND (target.UpdatedAt < source.UpdatedAt) AND (target.CostEUR <> source.CostEUR OR target.RouteId <> source.RouteId OR target.Deleted <> source.Deleted) THEN
		UPDATE SET 
			CostEUR = source.CostEUR, 
			CostLocalCurrency = source.CostLocalCurrency, 
			CostLocal = source.CostLocal,
			RouteId = source.RouteId,
			Deleted = source.Deleted, 
			UpdatedAt = source.UpdatedAt;

	PRINT [dbo].[Log_ROWCOUNT] ('rt.SupplierCostCoverage - merge');
	*/

	-- Update existing records in cost v1
	WITH v2 AS (
		SELECT 
			CAST(scc.OperatorId AS VARCHAR(6)) AS OperatorId,
			sc.ConnId, 
			scc.CostEUR AS Cost,
			1 - scc.Deleted AS Active,
			scc.UpdatedAt
		FROM rt.SupplierCostCoverage scc
			INNER JOIN rt.SupplierConn sc ON sc.ConnUid = scc.RouteUid
		WHERE scc.SmsTypeId = 1 
			AND scc.OperatorId IS NOT NULL
			--AND scc.UpdatedAt < @Now
	)
	UPDATE v1 SET Cost = IIF(v2.Active = 1, v2.Cost, 999), Active = v2.Active, UpdatedAt = v2.UpdatedAt
	--SELECT *
	FROM v2 INNER JOIN dbo.CPCost AS v1
		ON v1.Operator = v2.OperatorId AND v1.RouteId = v2.ConnId
	WHERE v1.UpdatedAt < v2.UpdatedAt
		AND (v1.Active <> v2.Active OR v1.Cost <> v2.Cost)

	PRINT [dbo].[Log_ROWCOUNT] ('dbo.CPCost - update from v2');
	
	-- Update existing records in cost v1
	WITH v2 AS (
		SELECT 
			CAST(scc.OperatorId AS VARCHAR(6)) AS OperatorId,
			sc.ConnId, 
			sc.ConnUid,
			scc.CostEUR AS Cost,
			1 - scc.Deleted AS Active,
			scc.UpdatedAt
		FROM rt.SupplierCostCoverage scc
			INNER JOIN rt.SupplierConn sc ON sc.ConnUid = scc.RouteUid
		WHERE scc.SmsTypeId = 1 
			AND scc.OperatorId IS NOT NULL -- exclude country-default cost
			AND scc.CostEUR > 0 -- exclude zero route
			AND scc.Deleted = 0
			--AND scc.UpdatedAt < @Now
	)
	INSERT INTO dbo.CPCost (Operator, RouteId, Cost, Active, UpdatedAt)
	SELECT v2.OperatorId, v2.ConnId, v2.Cost, v2.Active, v2.UpdatedAt
	--SELECT *
	--delete from scc
	FROM v2 LEFT JOIN dbo.CPCost AS v1
		ON v1.Operator = v2.OperatorId AND v1.RouteId = v2.ConnId
		--INNER JOIN rt.SupplierCostCoverage scc ON scc.RouteUid = v2.ConnUid AND scc.OperatorId = v2.OperatorId
	WHERE v1.Operator IS NULL

	PRINT [dbo].[Log_ROWCOUNT] ('dbo.CPCost - insert from v2')

	/* Deprecated */
	/*
	-- UPDATE dbo.PlanRouting
	UPDATE pr SET Cost = c.Cost, Active = c.Active
	--SELECT *
	FROM dbo.PlanRouting pr
		INNER JOIN dbo.CPCost c ON pr.Operator = c.Operator AND pr.RouteId = c.RouteId
	WHERE abs(pr.Cost - c.Cost) > 0.000001 /* PlanRouting.Cost has 4 digits only :( */
		AND c.Active = 1

	PRINT [dbo].[Log_ROWCOUNT] ('dbo.PlanRouting - update cost')
	
	-- All new subaccounts - to use Routing v2 (MAP)
	DECLARE @SubAccount TABLE (SubAccountId varchar(50))
	INSERT INTO ms.FeatureFilter_SmsRouter (SubAccountId, Priority, Country, OperatorId, IsActive, ApiVersion)
	OUTPUT inserted.SubAccountId INTO @SubAccount (SubAccountId)
	SELECT sa.SubAccountId, 100, NULL, NULL, 1, 'V2'
	FROM dbo.Account sa
	WHERE sa.Deleted = 0 
		AND sa.SubAccountUid > 20000
		AND sa.AccountId <> '1CSGtest1'
		AND NOT EXISTS (
			SELECT 1 
			FROM ms.FeatureFilter_SmsRouter f 
			WHERE f.SubAccountId = sa.SubAccountId)

	-- routing V1
	INSERT INTO rt.SubAccount_Default (SubAccountUid, RoutingPlanId_Default, PricingPlanId_Default)
	SELECT sa.SubAccountUid, 3 /* cp_curated routing */, 3 /* cp_curated pricing */
	FROM @SubAccount t
		INNER JOIN dbo.Account sa ON t.SubAccountId = sa.SubAccountId
	WHERE NOT EXISTS (SELECT 1 FROM rt.SubAccount_Default sd WHERE sd.SubAccountUid = sa.SubAccountUid)

	*/
END
