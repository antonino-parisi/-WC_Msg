-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-31
-- Description:	MAP Accounts - Get by filter
-- Supported @Type = CARD, BANK, ADJUST, TEST
-- =============================================
-- EXEC map.[BillingTransaction_Insert] @AccountUid = '47E0E533-14F0-E611-813F-06B9B96CA965', @Type = 'CARD'
CREATE PROCEDURE [map].[BillingTransaction_Insert]
	@AccountUid uniqueidentifier,
	@Type varchar(10),
	@Currency char(3),
	@Amount decimal(19,7),
	@MapUserId smallint,
	@Description nvarchar(500),
	--@PaymentProvider varchar(20) = NULL,	-- for Type=BANK
	@PaymentRef varchar(20) = NULL,			-- for Type=BANK
	@InvoiceDate date = NULL,				-- for Type=BANK
	@PaymentDate date = NULL				-- for Type=BANK
AS
BEGIN

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @AmountEUR decimal(19,7)
		SET @AmountEUR = mno.CurrencyConverter(@Amount, @Currency, 'EUR', DEFAULT)
	
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
            AmountEUR,
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
			@Type, -- Type - varchar
			'SUCCESS', -- TrxIntStatus - varchar
			'UNDEF', -- TrxExtStatus - varchar
			ISNULL(@PaymentRef, ''), -- InvoiceNumber - varchar
			@Currency, -- Currency - char
			@Amount, -- Amount - decimal
			@AmountEUR, -- AmountEUR - decimal
            @AmountEUR, -- AmountWithoutFee - decimal
			@AccountUid, -- AccountUid - uniqueidentifier
			NULL, -- UserId - uniqueidentifier
			'8x8', -- PaymentProvider - varchar
			@PaymentRef, -- PaymentRef - varchar
			NULL, -- PaymentError - varchar
			@Description, -- Description - nvarchar
			@InvoiceDate, -- InvoiceDate - date
			@PaymentDate, -- PaymentDate - date
			@MapUserId -- MapUserId - uniqueidentifier
		)

		---------------
		-- Adjust Account Balance using legacy code
		---------------
		IF @Description IS NULL
			SET @Description = '[' + @Type + '] Credit Account for ' + @Currency + ' ' + CAST(@Amount AS NVARCHAR(50))
	
		EXEC cp.AccountWallet_Change @AccountUid = @AccountUid, @Amount = @Amount, @Currency = @Currency, @Comment = @Description

		--DECLARE @AccountId varchar(50)
	
		--SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid
		--IF @AccountId IS NULL
		--	THROW 51002, 'AccountId does not exists', 1; 

		--IF @Description IS NULL
		--	SET @Description = '[' + @Type + '] Credit Account for EUR ' + CAST(@AmountEUR AS NVARCHAR(50))
	
		--EXEC dbo.sp_CreditAccount @AccountId, @Amount, @Currency, @Description

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
