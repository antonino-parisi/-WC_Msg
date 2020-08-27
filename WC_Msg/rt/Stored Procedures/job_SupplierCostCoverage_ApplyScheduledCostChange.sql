-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-07-16
-- =============================================
-- EXEC rt.[job_SupplierCostCoverage_ApplyScheduledCostChange]
CREATE PROCEDURE [rt].[job_SupplierCostCoverage_ApplyScheduledCostChange]
AS
BEGIN

	-- declaration of columns
	DECLARE @CostCoverageId int
	DECLARE @ConnUid int
	DECLARE @Country char(2)
	DECLARE @OperatorId int
	DECLARE @SmsTypeId tinyint	-- MO => 0, MT => 1
	DECLARE @CostLocal decimal(12,6)
	DECLARE @CostLocalCurrency char(3)
	DECLARE @Active bit	-- activate or deactivate cost rule

	-- Get 1st record
	SELECT TOP (1) @CostCoverageId = CostCoverageId
	--SELECT *
	FROM rt.SupplierCostCoverageFuture sc
	WHERE sc.EffectiveFrom <= SYSUTCDATETIME()
	ORDER BY sc.EffectiveFrom

	WHILE @CostCoverageId IS NOT NULL
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			SELECT TOP (1)
				@ConnUid = ConnUid,
				@Country = Country,
				@OperatorId = OperatorId,
				@SmsTypeId = SmsTypeId,
				@CostLocal = CostLocal,
				@CostLocalCurrency = CostLocalCurrency,
				@Active = Active
			FROM rt.SupplierCostCoverageFuture
			WHERE CostCoverageId = @CostCoverageId

			-- update cost coverage
			EXEC map.SupplierCostCoverage_Update
				@ConnUid = @ConnUid,
				@Country = @Country,
				@OperatorId = @OperatorId,
				@SmsTypeId = @SmsTypeId,
				@CostLocal = @CostLocal,
				@CostLocalCurrency = @CostLocalCurrency,
				@EffectiveFrom = NULL,	--always NOW
				@Active = @Active

			DELETE FROM rt.SupplierCostCoverageFuture WHERE CostCoverageId = @CostCoverageId
			
		END TRY
		BEGIN CATCH  
			PRINT ERROR_MESSAGE()

			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;  
		END CATCH;

		IF @@TRANCOUNT > 0  COMMIT TRANSACTION;

		--get next record in cycle
		SET @CostCoverageId = NULL
		SELECT TOP (1) @CostCoverageId = CostCoverageId
		FROM rt.SupplierCostCoverageFuture sc
		WHERE sc.EffectiveFrom <= SYSUTCDATETIME()
		ORDER BY sc.EffectiveFrom
	END

END
