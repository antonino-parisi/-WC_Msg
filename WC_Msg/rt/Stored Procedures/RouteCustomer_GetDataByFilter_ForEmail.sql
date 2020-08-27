
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-21
-- Description:	Data for Customer routing page
-- =============================================
-- Examples:
--	EXEC [rt].[RouteCustomer_GetDataByFilter_ForEmail] @SubAccountId='AGODA_1', @Country=NULL, @OperatorId=NULL, @RouteId=NULL
-- =============================================
CREATE PROCEDURE [rt].[RouteCustomer_GetDataByFilter_ForEmail]
	@SubAccountId varchar(50),
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@RouteId varchar(50) = NULL,
	@LastModifiedInMins int = NULL
AS
BEGIN

	/*
	--Sample filter
	DECLARE @SubAccountId varchar(50) = 'awesomeap_hq'
	DECLARE @Country char(2) = 'SG'
	DECLARE @OperatorId int = NULL
	DECLARE @RouteId varchar(50) = NULL
	*/

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

	INSERT INTO @Data (AccountId, SubAccountId, IsCustomRoute, RoutingGroup, IsActiveRoute, Country, CountryName, CountryPrefix, OperatorId, OperatorName, Priority, RouteId, Currency, Cost, Price, Margin, RoutingMode, LastModifiedTimeUtc, Comment)
	EXEC [rt].[RouteCustomer_GetDataByFilter_Basics] @SubAccountId = @SubAccountId, @Country = @Country,
		@OperatorId = @OperatorId, @RouteId = @RouteId, @LastModifiedInMins = @LastModifiedInMins, @MaxCount = 10000

	SELECT d.Country, d.CountryName, d.OperatorName, l.MCC, l.MNCs as MNC, d.Currency, d.Price
	FROM @Data d
		INNER JOIN 
		(
			SELECT OperatorId, MCC, MNCs = STUFF((
				SELECT N', ' + MNC 
				FROM dbo.OperatorIdLookup AS p2
				WHERE p2.operatorId = p.operatorId and p.MCC = p2.MCC ORDER BY CAST(MNC as int)
				FOR XML PATH(N'')), 1, 2, N'')
			FROM OperatorIdLookup AS p
			GROUP BY OperatorId,MCC
		) l
		ON d.OperatorId = l.OperatorId

END


