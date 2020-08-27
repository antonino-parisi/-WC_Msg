-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-09
-- =============================================
-- EXEC map.SupplierCostCoverage_Update ...
CREATE PROCEDURE [map].[SupplierCostCoverage_Update]
	--@FileId int,
	@ConnUid int,
	@Country char(2),
	@OperatorId int,
	@SmsTypeId tinyint,	-- MO => 0, MT => 1
	@CostLocal decimal(12,6),
	@CostLocalCurrency char(3),
	@EffectiveFrom datetime2(2) = NULL,	-- default = NOW
	@Active bit = 1	-- activate or deactivate cost rule
AS
BEGIN

	-- add scheduled cost update
	IF (@EffectiveFrom > DATEADD(MINUTE, 1, SYSUTCDATETIME()))
	BEGIN

		IF EXISTS (
			SELECT 1
			FROM rt.SupplierCostCoverageFuture 
			WHERE ConnUid = @ConnUid 
				AND Country = @Country
				AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
				AND SmsTypeId = @SmsTypeId
				AND EffectiveFrom = @EffectiveFrom
			)
		BEGIN
			UPDATE rt.SupplierCostCoverageFuture 
			SET CostLocal = @CostLocal, 
				CostLocalCurrency = @CostLocalCurrency,
				Active = @Active, CreatedAt = SYSUTCDATETIME()
			WHERE ConnUid = @ConnUid 
				AND Country = @Country
				AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
				AND SmsTypeId = @SmsTypeId
				AND EffectiveFrom = @EffectiveFrom
		END
		ELSE
		BEGIN
			INSERT INTO rt.SupplierCostCoverageFuture (
				ConnUid, Country, OperatorId, SmsTypeId, 
				CostLocal, CostLocalCurrency, Active,
				EffectiveFrom, CreatedAt
			)
			VALUES (
				@ConnUid, @Country, @OperatorId, @SmsTypeId, 
				@CostLocal, @CostLocalCurrency, @Active,
				@EffectiveFrom, SYSUTCDATETIME()
			)
		END

		PRINT dbo.Log_ROWCOUNT ('Insert to SupplierCostCoverageFuture')

		RETURN
	END

	-- logic of deactivating coverage
	IF @Active = 0
	BEGIN
		UPDATE rt.SupplierCostCoverage
		SET Deleted = 1
		--OUTPUT inserted.CostCoverageId
		WHERE RouteUid = @ConnUid 
			AND Country = @Country
			AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND SmsTypeId = @SmsTypeId
			AND Deleted = 0
		
		PRINT dbo.Log_ROWCOUNT ('Soft deleted in SupplierCostCoverage')
		RETURN
	END

	-- calculate CostEUR
	DECLARE @CostEUR decimal(12,6)
	
	IF @CostLocalCurrency = 'EUR'
		SET @CostEUR = @CostLocal
	ELSE
	BEGIN
		SELECT TOP 1 @CostEUR = Rate * @CostLocal
		FROM mno.CurrencyRate
		WHERE CurrencyFrom = @CostLocalCurrency AND CurrencyTo = 'EUR' AND IsCurrent = 1
		
		PRINT dbo.Log_ROWCOUNT ('Calculate CostEUR based on exchange rate')

		IF @CostEUR IS NULL
		BEGIN
			DECLARE @msg NVARCHAR(2048)
			SET @msg = 'No exchange rate exists for ' + @CostLocalCurrency;
			THROW 51000, @msg, 1;
		END
	END

	-- find current coverage row
	DECLARE @CostCoverageId int
	SELECT @CostCoverageId = CostCoverageId 
	FROM rt.SupplierCostCoverage
	WHERE RouteUid = @ConnUid 
		AND Country = @Country
		AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
		AND SmsTypeId = @SmsTypeId
		--AND Deleted = 0

	-- if exists current row
	IF @CostCoverageId IS NOT NULL
	BEGIN
		-- FYI: previous values will be saved to rt.SupplierCostCoverageHistory by trigger

		-- set new cost
		UPDATE rt.SupplierCostCoverage
		SET CostLocal = @CostLocal, 
			CostLocalCurrency = @CostLocalCurrency,
			CostEUR = @CostEUR,
			EffectiveFrom = SYSUTCDATETIME(), --@EffectiveFrom
			Deleted = 0
		--OUTPUT inserted.CostCoverageId -- creates issue
		WHERE CostCoverageId = @CostCoverageId

		PRINT dbo.Log_ROWCOUNT ('Updated Cost in SupplierCostCoverage')
	END
	ELSE
	-- add new coverage + cost as it's not exists
	BEGIN
		INSERT INTO rt.SupplierCostCoverage (
			RouteUid, Country, OperatorId, SmsTypeId, 
			CostLocal, CostLocalCurrency, CostEUR,
			EffectiveFrom, CreatedAt
		)
		--OUTPUT inserted.CostCoverageId  -- creates issue
		VALUES (
			@ConnUid, @Country, @OperatorId, @SmsTypeId, 
			@CostLocal, @CostLocalCurrency, @CostEUR, 
			SYSUTCDATETIME(), SYSUTCDATETIME())

		PRINT dbo.Log_ROWCOUNT ('Inserted new Cost to SupplierCostCoverage')
	END

END
