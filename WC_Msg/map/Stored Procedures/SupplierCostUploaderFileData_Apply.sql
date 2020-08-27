-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-05-22
-- =============================================
-- SAMPLE:
-- EXEC map.SupplierCostUploaderFileData_Apply @FileId = 1, @RecordId = 12
CREATE PROCEDURE [map].[SupplierCostUploaderFileData_Apply]
	@FileId int,
	@RecordId int
AS
BEGIN

	SET XACT_ABORT ON --Throw fatal error in case of any error inside nested SPs

	DECLARE @ConnUid int
	DECLARE @Country char(2)
	DECLARE @OperatorId int
	DECLARE @SmsTypeId tinyint	-- MO => 0, MT => 1
	DECLARE @CostLocal decimal(12,6)
	DECLARE @CostLocalCurrency char(3)
	DECLARE @EffectiveFrom datetime2(2) = NULL	-- default = NOW
	DECLARE @Active bit = 1	-- activate or deactivate cost rule

	SELECT 
		@ConnUid = ConnUid,
		@Country = Country,
		@OperatorId = OperatorId,
		@SmsTypeId = SmsTypeId,
		@CostLocal = Cost,
		@CostLocalCurrency = Currency,
		@EffectiveFrom = EffectiveFrom,
		@Active = Active
	FROM map.SupplierCostUploaderFileData
	WHERE RecordId = @RecordId AND FileId = @FileId AND IsValid = 1

	-- update cost coverage
	EXEC map.SupplierCostCoverage_Update
		--@FileId = @FileId,
		@ConnUid = @ConnUid,
		@Country = @Country,
		@OperatorId = @OperatorId,
		@SmsTypeId = @SmsTypeId,
		@CostLocal = @CostLocal,
		@CostLocalCurrency = @CostLocalCurrency,
		@EffectiveFrom = @EffectiveFrom,	-- default = NOW
		@Active = @Active
	
	--IF @@Error > 0
	UPDATE map.SupplierCostUploaderFileData SET Saved = 1 WHERE RecordId = @RecordId
	UPDATE map.SupplierCostUploaderFile SET ItemsSaved += 1	WHERE FileId = @FileId
END
