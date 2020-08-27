-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2018-11-27
-- =============================================
-- SELECT * FROM
-- cp.fnCoverageBySubAccount('B224F695-189D-E711-8141-06B9B96CA965',DEFAULT,DEFAULT,DEFAULT,DEFAULT) --dev
-- cp.fnCoverageBySubAccount('B224F695-189D-E711-8141-06B9B96CA965',DEFAULT,DEFAULT,DEFAULT,DEFAULT) --prod

CREATE FUNCTION cp.fnCoverageBySubAccount
(@AccountUid UNIQUEIDENTIFIER,
@UserId UNIQUEIDENTIFIER = NULL,
@Country CHAR(2) = NULL,
@SubAccountIds VARCHAR(1000) = NULL, -- comma-separated list
@LimitSubAccounts BIT = 0)
RETURNS @CoverageTable TABLE   
(
		SubAccountId VARCHAR(50) NOT NULL,
		Country CHAR(2) NOT NULL,
		CountryName NVARCHAR(50),
		OperatorId INT NULL,
		OperatorName NVARCHAR(255),
		MCC_List VARCHAR(50),
		MNC_List VARCHAR(200),
		Currency CHAR(3) NOT NULL,
		Price DECIMAL(12,6) NOT NULL,
		RuleSrc CHAR(1) NOT NULL,
		UNIQUE (SubAccountId, Country, OperatorId)
)
AS
BEGIN
	IF @UserId IS NOT NULL
		SELECT @LimitSubAccounts = LimitSubAccounts
		FROM cp.[User] 
		WHERE AccountUid = @AccountUid AND UserId = @UserId ;

	-- get pricing
	DECLARE @Data AS TABLE (
		SubAccountUid INT NOT NULL,
		SubAccountId VARCHAR(50) NOT NULL,
		Country CHAR(2) NOT NULL,
		OperatorId INT NULL,
		Currency CHAR(3) NOT NULL,
		Price DECIMAL(12,6) NOT NULL,
		RuleSrc CHAR(1) NOT NULL,
		UNIQUE (SubAccountUid, Country, OperatorId)
	) ;

	-- convert csv-string @SubAccountIds to table
	DECLARE @SubAccountT TABLE (SubAccountUid int UNIQUE, SubAccountId varchar(50) UNIQUE) ;

    INSERT INTO @SubAccountT (SubAccountUid, SubAccountId) 
	SELECT sa.SubAccountUid, sa.SubAccountId
	FROM cp.Account a  
		JOIN dbo.Account sa ON sa.AccountId = a.AccountId
	WHERE a.AccountUid = @AccountUid
		AND a.Deleted = 0
		AND sa.Active = 1 AND sa.Deleted = 0
		-- filter by allowed subaccounts for user
		AND (@LimitSubAccounts = 0 OR (@LimitSubAccounts = 1 AND
			sa.SubAccountUid IN (SELECT SubAccountUid FROM cp.UserSubAccount WHERE UserId = @UserId)
		))
		-- filter by SP input list
		AND (@SubAccountIds IS NULL OR (@SubAccountIds IS NOT NULL AND
			sa.SubAccountId IN (SELECT LTRIM(RTRIM(Item)) FROM dbo.SplitString(@SubAccountIds, ','))
		)) ;

	-- exit if no access to subaccounts
	IF (SELECT COUNT(1) FROM @SubAccountT) = 0 RETURN ;

	-- Step 1: Insert price from Member rules
	INSERT INTO @Data
	SELECT 
		t.SubAccountUid,
		t.SubAccountId,
		cgcS.Country, 
		cgcS.OperatorId, 
		cgcS.PriceCurrency Currency, 
		cgcS.Price,
		'M' AS RuleSrc
	FROM rt.CustomerGroupSubAccount cgs 
		JOIN @SubAccountT t ON t.SubAccountUid = cgs.SubAccountUid AND cgs.Deleted = 0 -- filter subaccounts
		JOIN rt.CustomerGroupCoverage cgcS ON 
			cgcS.CustomerGroupId = cgs.CustomerGroupId AND 
			cgcS.SubAccountUid = t.SubAccountUid AND
			cgcS.Deleted = 0 AND
			cgcS.TrafficCategory = 'DEF'
	WHERE ISNULL(@Country, cgcS.Country) = cgcS.Country ;

	-- Step 2: Insert price from Group rules
	INSERT INTO @Data
	SELECT 
		t.SubAccountUid,
		t.SubAccountId,
		cgcD.Country, 
		cgcD.OperatorId, 
		cgcD.PriceCurrency Currency, 
		cgcD.Price,
		'G' AS RuleSrc
	FROM rt.CustomerGroupSubAccount cgs 
		JOIN @SubAccountT t ON -- filter subaccounts
			t.SubAccountUid = cgs.SubAccountUid AND 
			cgs.Deleted = 0
		JOIN rt.CustomerGroupCoverage cgcD ON 
			cgcD.CustomerGroupId = cgs.CustomerGroupId AND 
			cgcD.SubAccountUid IS NULL AND
			cgcD.Deleted = 0 AND 
			cgcD.TrafficCategory = 'DEF'
	WHERE 
		ISNULL(@Country, cgcD.Country) = cgcD.Country
		AND NOT EXISTS (SELECT 1 FROM @Data
						WHERE SubAccountUid = t.SubAccountUid
							AND Country = cgcD.Country
							AND ISNULL(OperatorId, 0) = ISNULL(cgcD.OperatorId, 0)) ;

	-- Step 3: Insert price from default pricing plan
	INSERT INTO @Data
	SELECT 
		t.SubAccountUid, 
		t.SubAccountId,
		ppc.Country, 
		ppc.OperatorId, 
		ppc.Currency, 
		ppc.Price,
		'D' AS RuleSrc
	FROM rt.SubAccount_Default sa
		JOIN @SubAccountT t ON -- filter subaccounts
			t.SubAccountUid = sa.SubAccountUid AND 
			sa.Deleted = 0
		JOIN rt.PricingPlanCoverage ppc ON 
			ppc.PricingPlanId = sa.PricingPlanId_Default AND
			ppc.Deleted = 0
		JOIN rt.RoutingPlanCoverage rpc ON	-- extra filtering by existing routing
			rpc.RoutingPlanId = sa.RoutingPlanId_Default AND
			rpc.Country = ppc.Country AND
			ISNULL(rpc.OperatorId, 0) = ISNULL(ppc.OperatorId, 0) AND	-- TODO: not all combinations covered here
			rpc.Deleted = 0 AND
			rpc.TrafficCategory = 'DEF'
	WHERE 	
		ISNULL(@Country, ppc.Country) = ppc.Country
		AND NOT EXISTS (SELECT 1 FROM @Data
						WHERE SubAccountUid = t.SubAccountUid
							AND Country = ppc.Country
							AND ISNULL(OperatorId, 0) = ISNULL(ppc.OperatorId, 0)) ;

	-- final report
	INSERT INTO @CoverageTable
	SELECT 
		d.SubAccountId,
		d.Country, 
		c.CountryName, 
		d.OperatorId, 
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		o.MCC_List AS MCC, 
		o.MNC_List AS MNC, 
		d.Currency, 
		d.Price,
		d.RuleSrc
	FROM @Data d
		JOIN mno.Country c ON d.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON d.OperatorId = o.OperatorId
	ORDER BY d.SubAccountId, d.Country, d.OperatorId ;

	RETURN
END
