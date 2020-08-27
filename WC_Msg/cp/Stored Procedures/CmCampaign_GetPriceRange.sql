-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-09
-- =============================================
-- EXEC [cp].[CmCampaign_GetPriceRange] @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @SubAccountId = 'PEPSKWIK05-7rRF4_null3', @CountryList = 'RU,SG'
-- EXEC [cp].[CmCampaign_GetPriceRange] @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @SubAccountId = 'abc4_hq', @CountryList = 'RU,SG'
CREATE PROCEDURE [cp].[CmCampaign_GetPriceRange]
	@AccountUid uniqueidentifier,
	@SubAccountId varchar(50),
	@CountryList varchar(100)
AS
BEGIN
	
	-- prepare @SubAccountUids string
	DECLARE @SubAccountUids varchar(100)
	SELECT @SubAccountUids = CAST(sa.SubAccountUid as varchar(100)) 
	FROM ms.SubAccount sa
	WHERE sa.AccountUid = @AccountUid AND sa.SubAccountId = @SubAccountId
	
	-- main query
	SELECT 
		d.Country, 
		'EUR' AS Currency,
		mno.CurrencyConverter(MIN(d.PriceContract), d.PriceContractCurrency, 'EUR', DEFAULT) AS MinPrice, 
		mno.CurrencyConverter(MAX(d.PriceContract), d.PriceContractCurrency, 'EUR', DEFAULT) AS MaxPrice, 
		d.PriceContractCurrency AS ContractCurrency, -- all prices in contract currency
		MIN(d.PriceContract) AS MinPriceContract, 
		MAX(d.PriceContract) AS MaxPriceContract
	FROM rt.fnSMSPricingCoverage(@SubAccountUids, @CountryList, 1) d
	GROUP BY d.Country, d.PriceContractCurrency

	/* deprecated
	DECLARE @CountryListT TABLE (Country CHAR(2) PRIMARY KEY)
	INSERT INTO @CountryListT (Country)
	SELECT Item FROM dbo.SplitString(@CountryList, ',')

	DECLARE @Data AS TABLE (
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

	DECLARE @Country CHAR(2)
	DECLARE c Cursor FOR SELECT Country FROM @CountryListT
	OPEN c

	FETCH NEXT FROM c INTO @Country
	WHILE @@Fetch_Status=0 
	BEGIN
		
		-- insert routes for 1 country
		INSERT INTO @Data (AccountId, SubAccountId, IsCustomRoute, RoutingGroup, IsActiveRoute, Country, CountryName, CountryPrefix, OperatorId, OperatorName, Priority, RouteId, Currency, Cost, Price, Margin, RoutingMode, LastModifiedTimeUtc, Comment)
		EXEC [rt].[RouteCustomer_GetDataByFilter_Basics] @SubAccountId = @SubAccountId, @Country = @Country, @MaxCount = 200, @ReturnInputFilter = 1
		
		FETCH NEXT FROM c INTO @Country
	END

	CLOSE c
	DEALLOCATE c

	--debug
	--SELECT * FROM @Data d
	IF EXISTS (SELECT TOP (1) 1 FROM @Data)
	BEGIN
		SELECT d.Country, MIN(d.Currency) AS Currency /* <- will be a problem with different currencies*/, 
			MIN(d.Price) AS MinPrice, MAX(d.Price) AS MaxPrice
		FROM @Data d
		WHERE IsActiveRoute = 1
		GROUP BY d.Country
		ORDER BY 1
	END
	ELSE
	BEGIN
		-- showing for demo purposes
		SELECT Country, 'EUR' AS Currency, 0.001 AS MinPrice, 0.0012 AS MaxPrice
		FROM @CountryListT
	END
	*/
END
