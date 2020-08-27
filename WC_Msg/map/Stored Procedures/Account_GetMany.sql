-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-31
-- Description:	MAP Accounts - Get by filter
-- =============================================
-- EXEC map.Account_GetMany @AccountIdSearch = 'cebu'
-- EXEC map.Account_GetMany @CustomerType = 'E'
CREATE PROCEDURE [map].[Account_GetMany]
	@AccountUid uniqueidentifier = NULL,
	@AccountIdSearch varchar(50) = NULL,
	@CustomerType char(1) = NULL,
	@ManagerId smallint = NULL,
	@UpdatedBy smallint = NULL,
	@CompanyEntity varchar(10) = NULL,
	@PageOffset smallint = 0,
	@PageSize smallint = 100
AS
BEGIN
    
	DECLARE @AccountList TABLE (AccountUid uniqueidentifier NOT NULL PRIMARY KEY)

	-- filter list of Accounts
	INSERT INTO @AccountList (AccountUid)
	SELECT a.AccountUid
	FROM cp.Account a
		INNER JOIN ms.AccountMeta m ON a.AccountId = m.AccountId
	WHERE 
		-- NOTE: same filters are used below in code for TotalCount query. Keep them in sync
		(@AccountUid IS NULL  OR a.AccountUid = @AccountUid) AND
		(@CustomerType IS NULL OR m.CustomerType = @CustomerType) AND
		(@CompanyEntity IS NULL OR m.CompanyEntity = @CompanyEntity) AND
		(@ManagerId IS NULL OR m.ManagerId = @ManagerId) AND
		(@UpdatedBy IS NULL OR a.MapUpdatedBy = @UpdatedBy) AND
		(@AccountIdSearch IS NULL OR 
			(@AccountIdSearch IS NOT NULL AND (
				a.AccountId   LIKE '%'+@AccountIdSearch+'%' OR 
				a.AccountName LIKE '%'+@AccountIdSearch+'%' OR
                a.AccountUid IN (
                    SELECT AccountUid FROM cp.[User]
                    WHERE UserStatus = 'A' AND Login LIKE '%'+@AccountIdSearch+'%'
                    GROUP BY AccountUid
                )
                -- a.Email LIKE '%'+@AccountIdSearch+'%' 
				-- REMOVED: creates terrible execution plan. needs refactoring
				-- Option 1
				--OR a.AccountUid IN (
				--	SELECT sa.AccountUid FROM ms.SubAccount sa WHERE sa.SubAccountId LIKE '%'+@AccountIdSearch+'%'
				--)
				-- Option 2
				--OR EXISTS (SELECT TOP 1 1 FROM ms.SubAccount sa WHERE sa.AccountUid = a.AccountUid AND sa.SubAccountId LIKE '%'+@AccountIdSearch+'%')
			)))
	ORDER BY a.AccountId
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY

	-- get list
	SELECT
		a.AccountUid,
		a.AccountId,
		a.AccountName,
		m.CustomerType,
		UPPER(m.BillingMode) AS BillingMode,
		m.CompanyEntity,
		m.Currency,
		am.ManagerId,
		am.Name,
		am.Email,
		am.BU,
		/* WALLET */
		--ISNULL(ac.overdraftAuthorized, 0) AS CreditLimit_EUR,
		mno.CurrencyConverter(ISNULL(aw.OverdraftLimit, 0), aw.Currency, 'EUR', DEFAULT) AS CreditLimit_EUR,	-- deprecated
		mno.CurrencyConverter(ISNULL(aw.Balance, 0), aw.Currency, 'EUR', DEFAULT) AS Credit_EUR,	-- deprecated
		aw.Currency AS WalletCurrency,
		aw.Balance AS WalletBalance,
		aw.OverdraftLimit AS WalletOverdraftLimit,
		/* MAP Last updates */
		a.MapUpdatedAt,
		a.MapUpdatedBy,
		mapuser.Email AS MapUpdatedBy_Email,
		mapuser.FirstName + ' ' + mapuser.LastName AS MapUpdatedBy_FullName,
		/* Product Flags */
		a.Product_SMS,
		a.Product_CA,
		a.Product_VI,
		a.Product_VO,
		/* Counters */
		ISNULL(users.UserCount, 0) AS UserCount,
		ISNULL(sa.SubaccountCount, 0) AS SubaccountCount
	FROM cp.Account a
		INNER JOIN @AccountList al ON al.AccountUid = a.AccountUid
		INNER JOIN ms.AccountMeta m ON m.AccountId = a.AccountId
		LEFT JOIN ms.AccountManager am ON am.ManagerId = m.ManagerId
		LEFT JOIN dbo.AccountCredentials ac (NOLOCK) ON ac.AccountId = a.AccountId
		--LEFT JOIN dbo.AccountCredit cr (NOLOCK) ON cr.AccountId = a.AccountId
		LEFT JOIN cp.AccountWallet aw (NOLOCK) ON a.AccountUid = aw.AccountUid
		LEFT JOIN map.[User] mapuser ON a.MapUpdatedBy = mapuser.UserId
		LEFT JOIN (
			SELECT u.AccountUid, COUNT(u.UserId) AS UserCount
			FROM cp.[User] u (NOLOCK)
				INNER JOIN @AccountList al ON u.AccountUid = al.AccountUid
			WHERE u.UserStatus = 'A'
			GROUP BY u.AccountUid
		) users ON a.AccountUid = users.AccountUid
		LEFT JOIN (
			SELECT sa.AccountUid, COUNT(sa.SubAccountUid) AS SubaccountCount
			FROM ms.SubAccount sa (NOLOCK)
				INNER JOIN @AccountList al ON sa.AccountUid = al.AccountUid
			WHERE sa.Active = 1
			GROUP BY sa.AccountUid
		) sa ON a.AccountUid = sa.AccountUid
	
	-- total counter
	SELECT COUNT(a.AccountUid) AS TotalRows
	FROM cp.Account a
		INNER JOIN ms.AccountMeta m ON a.AccountId = m.AccountId
	WHERE 
		-- NOTE: same filters are used above in code for list query. Keep them in sync
		(@AccountUid IS NULL OR a.AccountUid = @AccountUid) AND
		(@CustomerType IS NULL OR m.CustomerType = @CustomerType) AND
		(@CompanyEntity IS NULL OR m.CompanyEntity = @CompanyEntity) AND
		(@ManagerId IS NULL OR m.ManagerId = @ManagerId) AND
		(@UpdatedBy IS NULL OR a.MapUpdatedBy = @UpdatedBy) AND
		(@AccountIdSearch IS NULL OR 
			(@AccountIdSearch IS NOT NULL AND (
			a.AccountId   LIKE '%'+@AccountIdSearch+'%' OR 
			a.AccountName LIKE '%'+@AccountIdSearch+'%'
			-- REMOVED: creates terrible execution plan. needs refactoring
			-- Option 1
			--OR a.AccountUid IN (
			--	SELECT sa.AccountUid FROM ms.SubAccount sa WHERE sa.SubAccountId LIKE '%'+@AccountIdSearch+'%'
			--)
			-- Option 2
			--OR EXISTS (SELECT TOP 1 1 FROM ms.SubAccount sa WHERE sa.AccountUid = a.AccountUid AND sa.SubAccountId LIKE '%'+@AccountIdSearch+'%')
			)))
	
END
