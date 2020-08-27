
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-10
-- Description:	Data for Customer routing page
-- =============================================
-- Examples:
-- EXEC rt.RouteCustomer_GetDataByFilter @OperatorId = '525001', @RouteId = 'Test page'
-- EXEC rt.RouteCustomer_GetDataByFilter @AccountID = 'eatigo', @Country = 'RU'
-- =============================================
CREATE PROCEDURE [rt].[RouteCustomer_GetDataByFilter]
	@AccountId varchar(50) = NULL,
	@SubAccountId varchar(50) = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@RouteId varchar(50) = NULL,
	@LastModifiedInMins int = NULL,
	@MaxCount int = 500
AS
BEGIN

	-- Return empty response in case of no filters defined
	IF (@AccountId IS NULL AND @SubAccountId IS NULL AND @Country IS NULL AND @OperatorId IS NULL AND @RouteId IS NULL)
		RETURN
	
	-- Constants
	--DECLARE @MaxCount INT = 500

	SET NOCOUNT ON;

	-- If filtering by OperatorId without Country filter then set Country of OperatorId
	IF (@OperatorId IS NOT NULL AND @Country IS NULL)
		SELECT @Country = CountryISO2alpha FROM mno.Operator WHERE OperatorId = @OperatorId

	-- If filtering by SubAccountID without AccountID filter then set AccountID of SubAccountID
	IF (@SubAccountId IS NOT NULL AND @AccountId IS NULL)
		SELECT @AccountId = AccountId FROM dbo.Account WHERE SubAccountId = @SubAccountId

	DECLARE @RouteCustomer AS TABLE (
		--ID INT IDENTITY(1,1),
		[AccountId] [varchar](50) NOT NULL,
		[SubAccountId] [varchar](50) NOT NULL,
		[IsCustomRoute] [bit] NOT NULL,
		[RoutingGroup] varchar(50) NOT NULL,
		[IsActiveRoute] [bit] NOT NULL,
		[MSISDNPrefix] varchar(16) NULL,
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
		[MessageBodyPrefix] [nvarchar](50) NULL,
		[SenderPoolId] [smallint] NULL,
		[SenderPoolName] varchar(50) NULL,
		[SenderMasking] varchar(50) NULL,
		[TrafficLast7days] [int] NULL,
		LastModifiedTimeUtc datetime NOT NULL,
		Comment nvarchar(500) NULL,
		UNIQUE CLUSTERED (AccountId, SubAccountId, Country, OperatorId, RouteId)
	);

	-- Main filter located in a separate SP, cause it's shared between multiple queries
	INSERT INTO @RouteCustomer (AccountId, SubAccountId, IsCustomRoute, RoutingGroup, IsActiveRoute, Country, CountryName, CountryPrefix, OperatorId, OperatorName, Priority, RouteId, Currency, Cost, Price, Margin, RoutingMode, LastModifiedTimeUtc, Comment)
	EXEC [rt].[RouteCustomer_GetDataByFilter_Basics] @AccountId = @AccountId, @SubAccountId = @SubAccountId, @Country = @Country,
		@OperatorId = @OperatorId, @RouteId = @RouteId, @LastModifiedInMins = @LastModifiedInMins, @MaxCount = 10000

	-----------------------------
	-- Set MessageBodyPrefix
	-----------------------------
	-- TODO: UNCOMMENT after migrating data
	--UPDATE rc
	--SET MessageBodyPrefix = mm.MessageBodyPrefix
	--FROM @RouteCustomer rc
	--	INNER JOIN optimus.MessageBodyPrefixMapping mm ON mm.SubAccountId = rc.SubAccountId AND mm.OperatorId = rc.OperatorId

	--UPDATE @RouteCustomer
	--SET MessageBodyPrefix = 'Defined on operator level'
	----SELECT *
	--FROM @RouteCustomer rc
	--WHERE rc.OperatorId IS NULL AND EXISTS (
	--	SELECT 1 
	--	FROM optimus.MessageBodyPrefixMapping mm 
	--		INNER JOIN mno.Operator o ON mm.OperatorId = o.OperatorId
	--	WHERE mm.SubAccountId = rc.SubAccountId AND o.CountryISO2alpha = ISNULL(rc.Country, o.CountryISO2alpha)
	--)

	-----------------------------
	-- Set SenderPool
	-----------------------------
	--UPDATE rc
	--SET SenderPoolId = sr.SenderPoolId, SenderPoolName = sr.SenderPoolName
	----SELECT *
	--FROM @RouteCustomer rc
	--	INNER JOIN optimus.SenderMaskingRules smr ON smr.OperatorId = rc.OperatorId AND smr.RouteId = rc.RouteId
	--	INNER JOIN optimus.SenderRotationPool sr ON sr.SenderPoolId = smr.NewSenderPoolId

	--UPDATE rc
	--SET SenderPoolName = 'Defined on operator level'
	----SELECT *
	--FROM @RouteCustomer rc
	--	INNER JOIN mno.Operator o ON ISNULL(rc.Country, o.CountryISO2alpha) = o.CountryISO2alpha
	--	INNER JOIN optimus.SenderMaskingRules smr ON smr.OperatorId = o.OperatorId AND smr.RouteId = rc.RouteId
	--	INNER JOIN optimus.SenderRotationPool sr ON sr.SenderPoolId = smr.NewSenderPoolId
	--WHERE rc.OperatorId IS NULL

	-- Final result
	-- Some part of presentaion logic is handled here which should be avoided/rewriten
	SELECT TOP (@MaxCount) AccountId, SubAccountId, RoutingGroup, IsActiveRoute, 
				Country, 
				CASE WHEN CountryName IS NULL THEN '<ALL>' ELSE CountryName + ' (+' + CountryPrefix + ')' END AS CountryName,
				CountryPrefix, OperatorId, ISNULL(OperatorName, '<ALL>') AS OperatorName, RouteId, Priority,
				Currency, CAST(Cost as decimal(10,6)) as Cost, CAST(Price as decimal(10,6)) as Price, CAST(Margin as decimal(10,6)) as Margin, 
				CASE RoutingMode WHEN 0 THEN 'Cheapest' WHEN 1 THEN 'Fixed' ELSE '' END AS RoutingMode, 
				MessageBodyPrefix, SenderPoolId, SenderPoolName, TrafficLast7days, 
				CONVERT(varchar(23),LastModifiedTimeUtc, 120) /* workaround of Goland issue*/ AS LastModifiedTimeUtc,
				Comment
	FROM @RouteCustomer
	ORDER BY AccountId, SubAccountId, IsCustomRoute DESC, CountryName, OperatorId, IsActiveRoute DESC, Priority DESC

END

