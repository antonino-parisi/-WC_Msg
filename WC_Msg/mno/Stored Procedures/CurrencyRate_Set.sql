CREATE PROCEDURE [mno].[CurrencyRate_Set]
	@CurrencyFrom char(3),
	@CurrencyTo char(3),
	@Rate decimal(18,10),
	@EffectiveFrom datetime2(0)
AS
BEGIN
	
	DECLARE @IsCurrent bit = 0
	DECLARE @Prev_id int
	DECLARE @Prev_EffectiveFrom datetime2(0)

	BEGIN TRANSACTION
	
	BEGIN TRY
		SELECT @Prev_id = id, @Prev_EffectiveFrom = EffectiveFrom
		FROM mno.CurrencyRateSource
		WHERE CurrencyFrom = @CurrencyFrom AND CurrencyTo = @CurrencyTo AND IsCurrent = 1

		-- to define, to set new rate as "current" or not
		IF @Prev_EffectiveFrom IS NULL OR (@EffectiveFrom >= @Prev_EffectiveFrom)
		BEGIN
			SET @IsCurrent = 1
			
			-- reset flag for previous record
			IF @EffectiveFrom > @Prev_EffectiveFrom
				UPDATE mno.CurrencyRateSource SET IsCurrent = 0 WHERE id = @Prev_id
		END
		

		IF EXISTS (
			SELECT 1 FROM mno.CurrencyRateSource 
			WHERE EffectiveFrom = @EffectiveFrom 
				AND CurrencyFrom = @CurrencyFrom 
				AND CurrencyTo = @CurrencyTo)
		BEGIN
			UPDATE mno.CurrencyRateSource
			SET Rate = @Rate, IsCurrent = @IsCurrent, UpdatedAt = sysutcdatetime()
			WHERE EffectiveFrom = @EffectiveFrom
				AND CurrencyFrom = @CurrencyFrom
				AND CurrencyTo = @CurrencyTo
		END
		ELSE
		BEGIN
			INSERT INTO mno.CurrencyRateSource (EffectiveFrom, CurrencyFrom, CurrencyTo, Rate, IsCurrent)
			VALUES (@EffectiveFrom, @CurrencyFrom, @CurrencyTo, @Rate, @IsCurrent)
		END

	END TRY
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  
	END CATCH;  

	IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
END