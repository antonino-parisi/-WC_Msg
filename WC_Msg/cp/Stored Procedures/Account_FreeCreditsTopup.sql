-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-28
-- =============================================
-- EXEC cp.Account_FreeCreditsTopup @AccountUid = '639250FE-E2E5-E611-813F-06B9B96CA965', @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468'
CREATE PROCEDURE [cp].[Account_FreeCreditsTopup]
	@AccountUid UNIQUEIDENTIFIER,
	@UserId UNIQUEIDENTIFIER
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		-- Verification stage
		DECLARE @FreeCreditsOffer decimal(12,4)
		DECLARE @Currency CHAR(3)

		SELECT @FreeCreditsOffer = FreeCreditsOffer, @Currency = aw.Currency
		FROM cp.Account a
			INNER JOIN cp.AccountWallet AS aw ON a.AccountUid = aw.AccountUid
		WHERE a.AccountUid = @AccountUid
		
		IF (@FreeCreditsOffer IS NULL OR @FreeCreditsOffer <= 0)
			THROW 51000, 'No free credits available', 1; 

		DECLARE @MSISDN bigint
		SELECT @MSISDN = u.MSISDN
			FROM cp.[User] u INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
			WHERE u.UserId = @UserId AND a.AccountUid = @AccountUid AND u.PhoneVerified = 1
		
		IF @MSISDN IS NULL
			THROW 51001, 'Phone is not verified', 1; 
	
		IF EXISTS (SELECT 1 FROM cp.FreeCreditsLog WHERE MSISDN = @MSISDN)
			THROW 51002, 'Phone is already used for free credits', 1; 
		
		-- Action stage (add credits)
		UPDATE cp.Account SET FreeCreditsOffer = 0 WHERE AccountUid = @AccountUid
		
		DECLARE @Comment NVARCHAR(50)
		SET @Comment = 'Free credits topup for ' + @Currency + CAST(@FreeCreditsOffer AS VARCHAR(50))
		EXEC cp.AccountWallet_Change @AccountUid = @AccountUid, @Amount = @FreeCreditsOffer, @Currency = @Currency, @Comment = @Comment

		INSERT INTO cp.FreeCreditsLog (MSISDN, AccountUid, UserId, Amount, Currency)
			VALUES (@MSISDN, @AccountUid, @UserId, @FreeCreditsOffer, @Currency) ;

		INSERT INTO ms.MsisdnWhitelist (AccountUid, Msisdn)
			VALUES (@AccountUid, @MSISDN) ;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
