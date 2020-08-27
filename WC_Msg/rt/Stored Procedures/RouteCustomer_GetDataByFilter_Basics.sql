-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-21
-- Description:	Get full routing for Customer, filtered
-- =============================================
-- Examples:
--	EXEC [rt].[RouteCustomer_GetDataByFilter_Basics] @SubAccountId='AGODA_1', @Country=NULL, @OperatorId=NULL, @RouteId=NULL
-- =============================================
CREATE PROCEDURE [rt].[RouteCustomer_GetDataByFilter_Basics]
	@AccountId varchar(50) = NULL,
	@SubAccountId varchar(50) = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@RouteId varchar(50) = NULL,
	@LastModifiedInMins int = NULL,
	@MaxCount int = 500,
	@ReturnInputFilter bit = 0
AS
BEGIN
	DECLARE @RouteCustomer AS TABLE (
		[AccountId] [varchar](50) NOT NULL,
		[SubAccountId] [varchar](50) NOT NULL,
		[IsCustomRoute] [bit] NOT NULL,
		[RoutingGroup] varchar(50) NOT NULL,
		[IsActiveRoute] [bit] NOT NULL,
		[Country] [char](2) NULL,
		[CountryName] nvarchar(50) NULL,
		[CountryPrefix] varchar(5) NULL,
		[OperatorId] [int] NULL,
		[OperatorName] nvarchar(255) NULL,
		[Priority] [tinyint] NOT NULL,
		[RouteId] [varchar](50) NOT NULL,
		[Currency] [char](3) NOT NULL,
		[Cost] real NOT NULL,
		[Price] real NOT NULL,
		[Margin] real NOT NULL,
		[RoutingMode] varchar(16) NULL,
		LastModifiedTimeUtc datetime NOT NULL,
		Comment nvarchar(500) NULL,
		UNIQUE CLUSTERED (AccountId, SubAccountId, Country, OperatorId, RouteId)
	);

	/*
	KNOWN BUG: In case of following conditions:
		1) there is filter by LastModifiedTimeUtc 
		2) modified records are in standard route
		3) amount of custom routes reached @MaxCount
	*/

	INSERT INTO @RouteCustomer (
		AccountId, SubAccountId, IsCustomRoute, RoutingGroup, IsActiveRoute, Country, 
		CountryName, CountryPrefix, OperatorId, OperatorName, RouteId, Priority, Currency, Cost, Price, Margin, 
		RoutingMode, LastModifiedTimeUtc, Comment)
	SELECT TOP (@MaxCount) rc.AccountId, rc.SubAccountId, 1 AS IsCustomRoute, 'Custom' AS RoutingGroup, rc.IsActiveRoute, 
		rc.Country, c.CountryName, c.DialCode AS CountryPrefix, rc.OperatorId, o.OperatorName, rc.RouteId, rc.Priority, 
		rc.Currency, rc.Cost, rc.Price, rc.Price - rc.Cost as Margin,
		rc.RoutingMode, rc.LastModifiedTimeUtc, rc.Comment
	FROM rt.RoutingView_Customer rc
		LEFT JOIN mno.Country c ON c.CountryISO2alpha = rc.Country
		LEFT JOIN mno.Operator o ON (rc.OperatorId IS NOT NULL AND rc.OperatorId = o.OperatorId)
	WHERE (rc.AccountId = @AccountId OR @AccountId IS NULL)
		AND (rc.SubAccountId = @SubAccountId OR @SubAccountId IS NULL)
		AND (rc.Country = @Country OR @Country IS NULL OR rc.Country IS NULL)
		AND (rc.OperatorId = @OperatorId OR @OperatorId IS NULL OR rc.OperatorId IS NULL)
		AND (rc.RouteId = @RouteId OR @RouteId IS NULL)

	-- Add standard/default routes
	IF (@AccountId IS NOT NULL OR @SubAccountId IS NOT NULL AND @@ROWCOUNT < @MaxCount)
	BEGIN
		INSERT INTO @RouteCustomer (
			AccountId, SubAccountId, IsCustomRoute,	RoutingGroup, IsActiveRoute, Country, CountryName, CountryPrefix, 
			OperatorId, OperatorName, RouteId, Priority, Currency, Cost, Price, Margin, RoutingMode, LastModifiedTimeUtc, Comment)
		SELECT TOP (@MaxCount) a.AccountId, a.SubAccountId, 0 AS IsCustomRoute, a.StandardRouteId, rcd.IsActiveRoute, 
				rcd.Country, c.CountryName, c.DialCode, rcd.OperatorId, o.OperatorName, rcd.RouteId, rcd.Priority,
				rcd.Currency, rcd.Cost, rcd.Price, rcd.Price - rcd.Cost as Margin,
				rcd.RoutingMode, rcd.LastModifiedTimeUtc, rcd.Comment

		FROM dbo.Account a
			INNER JOIN dbo.StandardAccount sa ON a.StandardRouteId = sa.StandardRouteIdName
			INNER JOIN rt.RoutingView_Customer rcd ON rcd.SubAccountId = sa.SubAccountId /*StandardSubAccountId*/
			LEFT JOIN  @RouteCustomer rc ON rc.Country = rcd.Country AND rc.OperatorId = rcd.OperatorId
			LEFT JOIN mno.Country c ON c.CountryISO2alpha = rcd.Country
			LEFT JOIN mno.Operator o ON rcd.OperatorId = o.OperatorId

		WHERE (a.AccountId = @AccountId OR @AccountId IS NULL)
			AND (a.SubAccountId = @SubAccountId OR @SubAccountId IS NULL)
			AND (rcd.Country = @Country OR @Country IS NULL OR rcd.Country IS NULL)
			AND (rcd.OperatorId = @OperatorId OR @OperatorId IS NULL OR rcd.OperatorId IS NULL)
			AND (rcd.RouteId = @RouteId OR @RouteId IS NULL)
			AND rc.AccountId IS NULL -- exclude CustomRules
			--AND a.StandardSubAccountId IS NOT NULL AND a.StandardRouteId IS NOT NULL
	END

	SELECT AccountId, IIF(@ReturnInputFilter = 1, @SubAccountId, SubAccountId) AS SubAccountId, 
		IsCustomRoute, RoutingGroup, IsActiveRoute, 
		IIF(@ReturnInputFilter = 1, @Country, Country) AS Country, CountryName, 
		CountryPrefix, OperatorId, OperatorName, Priority, RouteId, Currency, 
		Cost, Price, Margin, RoutingMode, LastModifiedTimeUtc, Comment
	FROM @RouteCustomer
	WHERE (@LastModifiedInMins IS NULL OR LastModifiedTimeUtc >= DATEADD(MINUTE, -@LastModifiedInMins, GETUTCDATE()))
END
