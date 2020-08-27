
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-11-03
-- Description:	Sync RoutingData from MessageSphere v1
-- =============================================
-- EXEC morph.job_SyncRoutingFromMS
CREATE PROCEDURE [morph].[job_SyncRoutingFromMS]
AS
BEGIN

	SET NOCOUNT ON;

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Starting sync'

	DECLARE @RT as TABLE (
		id int IDENTITY (1,1) NOT NULL PRIMARY KEY,
		SubAccountId varchar(50) NOT NULL,
		Country char(2) NULL,
		OperatorId int NULL,
		IsActiveRoute bit NOT NULL,
		RouteStrategy tinyint NOT NULL,
		Currency char(3) NOT NULL,
		Price real NOT NULL,
		UseCheapestRoute bit NOT NULL,
		-----------------
		DataSourceId tinyint NOT NULL,
		StartTime time(0) NOT NULL,
		EndTime time(0) NOT NULL,
		Weight tinyint NOT NULL,
		RouteId varchar(50) NOT NULL,
		--RouteId_Fallback varchar(50) NULL,
		morphRuleId int NULL,
		UNIQUE CLUSTERED (SubAccountId, Country, OperatorId)
	)

	DECLARE @link AS TABLE (
		SubAccountId VARCHAR(50) NOT NULL,
		Country CHAR(2) NULL,
		OperatorId INT NULL,
		RuleId INT NOT NULL
	)

	--IF EXISTS(SELECT * --TOP (1) 1 
	--	FROM dbo.PlanRouting p
	--		LEFT JOIN mno.Operator op ON TRY_PARSE(p.Operator as int) = op.OperatorId
	--	WHERE TRY_PARSE(p.Operator as int) IS NOT NULL AND op.OperatorId IS NULL)
	--BEGIN
	--	THROW 51000, 'Foreign key error. Table ''PlanRouting'' has OperatorId that missing in table ''mno.Operator''. Fix this, please.', 1;
	--END

	--IF EXISTS(SELECT TOP (1) 1 
	--	FROM dbo.PlanRouting p
	--		LEFT JOIN dbo.Account a ON p.SubAccountId = a.SubAccountId
	--		LEFT JOIN dbo.StandardAccount sa ON p.SubAccountId = sa.SubAccountId
	--	WHERE a.SubAccountId IS NULL AND sa.SubAccountId IS NULL)
	--BEGIN
	--	THROW 51000, 'Foreign key error. Table ''PlanRouting'' has SubAccountId that missing in table ''dbo.Account''. Fix this, please.', 1;
	--END

	INSERT INTO @rt (SubAccountId, Country, OperatorId, IsActiveRoute, RouteStrategy, Currency, Price, UseCheapestRoute, DataSourceId, StartTime, EndTime, Weight, RouteId)
	SELECT SubAccountId, ISNULL(op.CountryISO2alpha, c.CountryISO2alpha) AS CountryISO2alpha, op.OperatorId as OperatorId, 
		1 as IsActiveRoute, 1 as RouteStrategy, 'EUR' as Currency, Price, ISNULL(TariffRoute, 0) as UseCheapestRoute, 
		1 as DataSourceId, '00:00:00' as StartTime, '23:59:59' as EndTime, 1 as Weight, RouteId
	FROM dbo.PlanRouting p
		LEFT JOIN mno.Operator op ON TRY_PARSE(p.Operator as int) = op.OperatorId 
		LEFT JOIN mno.Country c ON p.Prefix = c.DialCode + '%' AND TRY_PARSE(p.Operator as int) IS NULL
	WHERE p.Active = 1 AND p.SubAccountId <> '*'
		-- check for missing OperatorId in mno.Operator
		AND (TRY_PARSE(p.Operator as int) IS NULL OR (TRY_PARSE(p.Operator as int) IS NOT NULL AND op.OperatorId IS NOT NULL))
		and LEN(Prefix) < 5
	ORDER BY 1,2,3

	PRINT [dbo].[Log_ROWCOUNT] ('Get records from dbo.PlanRouting to sync')

	IF (SELECT COUNT(*) FROM @rt) = 0
		THROW 51000, 'Error in sync', 1;

	-- *** UPDATE PROCESS ***
	UPDATE rt
	SET morphRuleId = CASE mr.DataSourceId WHEN 1 THEN mr.RuleId ELSE -1 END /* set linked morph.RuleId */
	FROM morph.Routing mr
		INNER JOIN @rt rt ON mr.SubAccountId = rt.SubAccountId 
			AND ISNULL(mr.Country, 'ALL') = ISNULL(rt.Country, 'ALL')
			AND ISNULL(mr.OperatorId, -1) = ISNULL(rt.OperatorId, -1)
			AND mr.IsActiveRoute = 1 and rt.IsActiveRoute = 1
			--AND mr.DataSourceId = 1 /* Source of old PlanRouting */
	
	PRINT [dbo].[Log_ROWCOUNT] ('Map RuleId from morph.Routing')

	-- DEBUG
	-- SELECT * FROM @rt

	-- UPDATE existing records
	UPDATE mr
	SET RouteStrategy = rt.RouteStrategy, Currency = rt.Currency, Price = rt.Price, UseCheapestRoute = rt.UseCheapestRoute
	FROM morph.Routing mr
		INNER JOIN @rt rt ON mr.RuleId = rt.morphRuleId
	WHERE mr.RouteStrategy <> rt.RouteStrategy OR mr.Currency <> rt.Currency OR mr.Price <> rt.Price OR mr.UseCheapestRoute <> rt.UseCheapestRoute

	PRINT [dbo].[Log_ROWCOUNT] ('Update to morph.Routing')

	UPDATE mrr
	SET RouteId = rt.RouteId
	FROM morph.RoutingRule mrr
		INNER JOIN @rt rt ON mrr.RuleId = rt.morphRuleId
	WHERE mrr.RouteId <> rt.RouteId

	PRINT [dbo].[Log_ROWCOUNT] ('Updates to morph.RoutingRule')

	---- INSERT new records
	INSERT INTO morph.Routing (SubAccountId, Country, OperatorId, IsActiveRoute, RouteStrategy, Currency, Price, UseCheapestRoute, DataSourceId)
		OUTPUT inserted.SubAccountId, inserted.Country, inserted.OperatorId, inserted.RuleId 
		INTO @link(SubAccountId, Country, OperatorId, RuleId)
	SELECT SubAccountId, rt.Country, rt.OperatorId, IsActiveRoute, RouteStrategy, Currency, Price, UseCheapestRoute, DataSourceId 
	FROM @RT AS rt
	WHERE rt.morphRuleId IS NULL

	PRINT [dbo].[Log_ROWCOUNT] ('Insert to morph.Routing')

	INSERT INTO morph.RoutingRule (RuleId, StartTime, EndTime, Weight, RouteId)
	SELECT l.RuleId, StartTime, EndTime, Weight, RouteId
	FROM @RT as rt
		INNER JOIN @link as l ON rt.SubAccountId = l.SubAccountId
			AND ISNULL(l.Country, 'ALL') = ISNULL(rt.Country, 'ALL')
			AND ISNULL(l.OperatorId, -1) = ISNULL(rt.OperatorId, -1)
			AND rt.IsActiveRoute = 1
	
	PRINT [dbo].[Log_ROWCOUNT] ('Insert to morph.RoutingRule')

	-- DELETE removed records
	DELETE FROM @link 

	INSERT INTO @link (SubAccountId, Country, OperatorId, RuleId)
	SELECT SubAccountId, Country, OperatorId, RuleId
	FROM morph.Routing mr
	WHERE mr.DataSourceId = 1 
		AND NOT EXISTS (
			SELECT 1 FROM @rt rt WHERE mr.SubAccountId = rt.SubAccountId 
				AND ISNULL(mr.Country, 'ALL') = ISNULL(rt.Country, 'ALL')
				AND ISNULL(mr.OperatorId, -1) = ISNULL(rt.OperatorId, -1)
				AND mr.IsActiveRoute = 1 and rt.IsActiveRoute = 1
				AND mr.DataSourceId = 1 /* Source of old PlanRouting */ 
			)

	--DEBUG
	--SELECT * FROM @link
	
	DELETE FROM mrr
	FROM morph.RoutingRule mrr
		INNER JOIN @link l ON l.RuleId = mrr.RuleId
	
	PRINT [dbo].[Log_ROWCOUNT] ('Delete from morph.RoutingRule')

	DELETE FROM mr
	FROM morph.Routing mr
		INNER JOIN @link l ON l.RuleId = mr.RuleId

	PRINT [dbo].[Log_ROWCOUNT] ('Delete from morph.Routing')
	
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Finished sync'
END
