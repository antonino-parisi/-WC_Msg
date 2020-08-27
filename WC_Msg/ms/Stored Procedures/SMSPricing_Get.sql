-- =============================================
-- Author: Anton Shchekalov
-- Description:	
-- Changes: 
--	2020-08-12 - Created
-- =============================================
 --EXEC ms.SMSPricing_Get @AccountUid = 'CD23F695-189D-E711-8141-06B9B96CA965' -- correct call with valid accountID
 --EXEC ms.SMSPricing_Get @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @direction=1
 --EXEC ms.SMSPricing_Get @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @Country='PH',@OperatorId=515088
 --EXEC ms.SMSPricing_Get @AccountUid = 'CD23F695-189D-E711-8141-06B9B96CA965', @SubAccountUid= 2 ,@Country='AM', @OperatorId=283001,@MCC=283,@MNC=5  
 --EXEC ms.SMSPricing_Get @AccountUid = 'CD23F695-189D-E711-8141-06B9B96CA968' --- accountid not found
 --EXEC ms.SMSPricing_Get @AccountUid = '' -- empty accounid
 --EXEC ms.SMSPricing_Get @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965',@MCC=202,@MNC=10,@Country='GR'
CREATE PROCEDURE [ms].[SMSPricing_Get]
	@AccountUid UNIQUEIDENTIFIER,	-- mandatory
	@SubAccountUid INT = NULL,		-- optional
	@Country CHAR(2) = NULL,		-- optional
	@OperatorId INT = NULL,			-- optional
	@MCC SMALLINT = NULL,			-- optional
	@MNC SMALLINT = NULL,			-- optional, needs MCC as pair
	@direction bit = NULL			-- optional

AS BEGIN

	-- Params Validation step
	IF (@MNC IS NOT NULL AND @MCC IS NULL) or (@MNC IS  NULL AND @MCC IS NOT NULL)
		THROW 51000, 'The pair MNC MCC must be specified', 1;

	-- get a list of opertators if @MNC @MCC filter is present
	IF (@MNC is not null and @MCC is not null)
	BEGIN 

		DECLARE @OperatorIdFilter TABLE( OperatorId int primary key)
		INSERT INTO @OperatorIdFilter
		SELECT
			opl.OperatorId
		FROM mno.OperatorIdLookup opl
		INNER JOIN mno.Operator op on opl.OperatorId= op.OperatorId
		WHERE
			opl.MCC = @MCC and opl.MNC=@MNC
			and CountryISO2alpha = COALESCE(NULLIF(@Country, ''), CountryISO2alpha)
		GROUP BY opl.OperatorId

		IF (SELECT count(*) FROM @OperatorIdFilter)=0
			THROW 51002, 'Combination of MNC MCC and Country not found', 1;

		SET @OperatorId=(SELECT OperatorId FROM @OperatorIdFilter)

	END

	-- convert list of SubAccounts to comma-separated string
	DECLARE @SubAccountUids VARCHAR(250) = ''
	SELECT @SubAccountUids = @SubAccountUids + CAST(SubAccountUid AS varchar(10)) + ',' 
	FROM ms.SubAccount AS sa
	WHERE 
		sa.AccountUid = @AccountUid AND 
		(@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))

	DECLARE @SubAccountT TABLE (SubAccountUid int PRIMARY KEY);
    INSERT INTO @SubAccountT (SubAccountUid)
	SELECT Item FROM dbo.SplitString_Int(@SubAccountUids, ',')
		
	IF (isnull(@SubAccountUids,'') = '')
		THROW 51001, 'No valid subaccounts', 1;

	DECLARE @pricing_output TABLE (
		SubAccountUid INT, 
		SubAccountId VARCHAR(50), 
		Country CHAR(2), 
		CountryName VARCHAR(50), 
		OperatorId INT, 
		OperatorName VARCHAR(255), 
		Currency CHAR(3), 
		Price DECIMAL(19, 7), 
		DialCode varchar(10));

	INSERT INTO @pricing_output
	SELECT 
		sa.SubAccountUid,
		sa.SubAccountId, 
		d.Country, 
		c.CountryName, 
		d.OperatorId, -- when null it is the default price for the country
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		d.PriceContractCurrency AS Currency,	-- this is Account Currency
		d.PriceContract AS Price,		-- this is price in Account Currency
		c.DialCode
		--,1 as direction
	FROM rt.fnSMSPricingCoverage(@SubAccountUids, @Country, 1) d
		INNER JOIN mno.Country c ON d.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON d.OperatorId = o.OperatorId
		INNER JOIN ms.SubAccount sa ON sa.SubAccountUid = d.SubAccountUid
	WHERE
		( d.OperatorId = COALESCE(NULLIF(@OperatorId, ''), d.OperatorId) or (d.OperatorId is null and @OperatorId is null))
		AND
		( @direction is null or 1=@direction)
	ORDER BY 
		sa.SubAccountId,
		d.Country,
		d.OperatorId

	-- direction 1 output
	SELECT 
		* 
	FROM @pricing_output

	-- direction 0 output
	SELECT 
		sa.SubAccountUid,
		sa.SubAccountId,
		ipc.VNCountry AS Country,
		c.CountryName AS CountryName,
		--ipc.MSISDNOperatorId AS OperatorId,
		--ipc.Currency,
		--ipc.PricePerSms as Price,
		--,0 as direction,
		ipc.VNType,
		c.DialCode,
		saprice.Currency  AS Currency,
		mno.CurrencyConverter(ipc.PricePerSms, ipc.Currency, saprice.Currency, DEFAULT) AS Price
	FROM rt.InboundPriceCoverage ipc
	INNER JOIN ms.SubAccount sa on ipc.SubaccountUid= sa.SubAccountUid
	INNER JOIN mno.Country c on ipc.VNCountry= c.CountryISO2alpha
	INNER JOIN @SubAccountT saT on ipc.SubaccountUid=saT.SubAccountUid
	INNER JOIN (
			SELECT 
				sa.SubAccountUid, 
				ISNULL(am.Currency, 'EUR') AS Currency
			FROM ms.SubAccount sa
				INNER JOIN cp.Account a ON sa.AccountUid = a.AccountUid
				LEFT JOIN ms.AccountMeta am ON a.AccountId = am.AccountId
		) saprice ON ipc.SubaccountUid = saprice.SubAccountUid
	LEFT JOIN mno.Operator o ON o.OperatorId= ipc.MSISDNOperatorId
	WHERE
		( @direction IS NULL OR 0=@direction)
		AND SYSUTCDATETIME() >= BillingStart and SYSUTCDATETIME() < BillingEnd
		AND ipc.VNCountry = COALESCE(NULLIF(@Country, ''), ipc.VNCountry)
		AND ( ipc.MSISDNOperatorId = COALESCE(NULLIF(@OperatorId, ''), ipc.MSISDNOperatorId) 
			OR (ipc.MSISDNOperatorId IS NULL AND @OperatorId IS NULL))
		AND ISNULL(o.Active,1) = 1

	-- give back mcc mnc based on OperatorId of the inbound outbound queries
	SELECT 
		opl.MCC AS MCC,	
		opl.MNC AS MNC,
		opl.OperatorId
	FROM mno.OperatorIdLookup opl
	LEFT JOIN @pricing_output po on po.OperatorId=opl.OperatorId
	WHERE 
		po.OperatorId IS NOT NULL
	GROUP BY 
		opl.MCC,	
		opl.MNC, 
		opl.OperatorId

	RETURN 0;
END
