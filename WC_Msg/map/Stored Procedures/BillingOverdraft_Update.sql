-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-31
-- Description:	MAP Accounts - Get by filter
-- Supported @Type = CARD, BANK, ADJUST, TEST
-- =============================================
-- EXEC map.BillingOverdraft_Update @AccountUid = '47E0E533-14F0-E611-813F-06B9B96CA965', @Currency = 'EUR', @Overdraft = -10, @MapUserId = 1, @Description = 'TEST'
CREATE PROCEDURE [map].[BillingOverdraft_Update]
	@AccountUid uniqueidentifier,
	@Currency char(3),
	@Overdraft decimal(18,6),
	@MapUserId smallint,
	@Description nvarchar(500)
AS
BEGIN

	BEGIN TRY
	BEGIN TRANSACTION

		-- main update
		UPDATE cp.AccountWallet 
		SET OverdraftLimit = mno.CurrencyConverter(@Overdraft, @Currency, Currency, DEFAULT)
		WHERE AccountUid = @AccountUid AND Currency = @Currency

		--IF @@rowcount = 0
		--	THROW 51003, 'Update failed. Potentially Wallet Currency mismatch', 1; 

		DECLARE @OverdraftEUR decimal(18,6)
		SET @OverdraftEUR = mno.CurrencyConverter(@Overdraft, @Currency, 'EUR', DEFAULT)
	
		-- log event of OVerdraft change
		INSERT cp.BillingTransaction
		(
			--TrxId - column value is auto-generated
			CreatedAt,
			UpdatedAt,
			Type,
			TrxIntStatus,
			TrxExtStatus,
			InvoiceNumber,
			Currency,
			Amount,
			AmountWithoutFee,
			AccountUid,
			UserId,
			PaymentProvider,
			PaymentRef,
			PaymentError,
			Description,
			InvoiceDate,
			PaymentDate,
			MapUserId
		)
		VALUES
		(
			-- TrxId - int
			SYSUTCDATETIME(), -- CreatedAt - datetime2
			SYSUTCDATETIME(), -- UpdatedAt - datetime2
			'OVERDRAFT', -- Type - varchar
			'UNDEF', -- TrxIntStatus - varchar
			'UNDEF', -- TrxExtStatus - varchar
			'', -- InvoiceNumber - varchar
			@Currency, -- Currency - char
			@Overdraft, -- Amount - decimal
			@OverdraftEUR, -- AmountEUR - decimal
			@AccountUid, -- AccountUid - uniqueidentifier
			NULL, -- UserId - uniqueidentifier
			'NA', -- PaymentProvider - varchar
			NULL, -- PaymentRef - varchar
			NULL, -- PaymentError - varchar
			@Description, -- Description - nvarchar
			NULL, -- InvoiceDate - date
			NULL, -- PaymentDate - date
			@MapUserId -- MapUserId - uniqueidentifier
		)

		---------------
		-- Adjust Overdraft in legacy table
		---------------
		DECLARE @AccountId varchar(50)
	
		SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid
		IF @AccountId IS NULL
			THROW 51002, 'AccountId does not exists', 1; 

		UPDATE dbo.AccountCredentials
		SET overdraftAuthorized = @OverdraftEUR, OutOfCredit = 0
		WHERE AccountId = @AccountId

		UPDATE dbo.AccountCredit SET ValidCredit = 1 WHERE AccountId = @AccountId

		-- track last change
		UPDATE cp.Account
		SET MapUpdatedBy = @MapUserId, MapUpdatedAt = SYSUTCDATETIME()
		WHERE AccountUid = @AccountUid

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
