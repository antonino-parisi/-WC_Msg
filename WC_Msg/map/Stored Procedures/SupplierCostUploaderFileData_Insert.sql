
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-19
-- =============================================
-- EXECUTE map.SupplierCostUploaderFileData_Insert ...
CREATE PROCEDURE [map].[SupplierCostUploaderFileData_Insert]
	@FileId int,
	--@IsValid bit,			-- 1 = valid, 0 - invalid
	@ConnId varchar(50),
	@MCC smallint,
	@MNC smallint,
	@SmsType varchar(10),	-- expects 'MO' or 'MT'
	@Cost decimal(12,6),
	@Currency char(3),
	@EffectiveFrom datetime2(2) = NULL,	-- NULL => NOW
	@Active bit = 1	-- activate or deactivate cost rule
AS
BEGIN

	-- get ConnUid
	SET @ConnId = RTRIM(LTRIM(@ConnId))
	DECLARE @ConnUid int
	
	SELECT @ConnUid = ConnUid 
	FROM rt.SupplierConn
	WHERE ConnId = @ConnId

	-- get Operator
	DECLARE @Country char(2) = NULL, @OperatorId int = -1
	SELECT 
		@OperatorId = l.OperatorId, 
		@Country = o.CountryISO2alpha
	FROM mno.OperatorIdLookup l
		INNER JOIN mno.Operator o ON l.OperatorId = o.OperatorId
	WHERE MCC = @MCC AND MNC = @MNC

	-- get country only
	IF @Country IS NULL AND @MCC IS NOT NULL
		SELECT TOP 1 @Country = CountryISO2alpha FROM mno.Country WHERE MCCDefault = @MCC

	-- get @SmsTypeId
	DECLARE @SmsTypeId tinyint
	IF UPPER(RTRIM(LTRIM(@SmsType))) = 'MO' SET @SmsTypeId = 0
	IF UPPER(RTRIM(LTRIM(@SmsType))) = 'MT' SET @SmsTypeId = 1

	-- Validation steps
	DECLARE @ErrorCode varchar(500) = ''
	DECLARE @IsValid bit = 1 ;

	IF (@ConnUid IS NULL)	SET @ErrorCode += 'InvalidConnection,'
	IF (@Country IS NULL)	SET @ErrorCode += 'InvalidCountry,'
	IF (@Country IS NOT NULL AND @OperatorId < 0)SET @ErrorCode += 'InvalidOperator,'
	IF (@SmsTypeId IS NULL) SET @ErrorCode += 'InvalidSmsType,'
	IF (@Active IS NULL)	SET @ErrorCode += 'InvalidActive,'
	IF (@Cost < 0)			SET @ErrorCode += 'InvalidCost,'
	IF (@Cost IS NULL)		SET @ErrorCode += 'EmptyCost,'
	
	IF (@EffectiveFrom IS NULL)		SET @ErrorCode += 'EffectiveFromInvalid,'
	IF (@EffectiveFrom < DATEADD(MINUTE, -5, SYSUTCDATETIME()))	SET @ErrorCode += 'NoBackDate,'
	IF (@MCC IS NULL OR @MCC NOT BETWEEN 100 AND 999) SET @ErrorCode += 'InvalidMCCFormat,'
	IF (@MNC IS NOT NULL AND @MNC NOT BETWEEN 0 AND 999) SET @ErrorCode += 'InvalidMNCFormat,'
	IF @Active = 1 AND @Currency <> 'EUR' AND NOT EXISTS (SELECT 1 FROM mno.CurrencyRate WHERE CurrencyFrom = @Currency AND CurrencyTo = 'EUR' AND IsCurrent = 1)
		SET @ErrorCode += 'InvalidCurrency,'

	IF LEN(@ErrorCode) = 0 -- continue if there's no ridiculous error
		BEGIN
			-- Check for duplicates in the same upload
			DECLARE @AnotherRecordId int, @AnotherCostEUR decimal(12,6) ;

			SELECT TOP 1 --@AnotherRecordId = RecordId, @AnotherCost = Cost, @IsValid = IsValid
				@AnotherRecordId = RecordId, 
				@AnotherCostEUR = mno.CurrencyConverter(Cost, Currency, 'EUR', DEFAULT), 
				@IsValid = IsValid
			FROM map.SupplierCostUploaderFileData
			WHERE (IsValid = 1 OR (IsValid = 0 AND CHARINDEX('NoChanges',Errorcode) <> 0))
				AND FileId = @FileId 
				AND ConnUid = @ConnUid
				AND ISNULL(OperatorId, -2) = ISNULL(@OperatorId, -2)
				--AND Currency = @Currency
				AND SmsTypeId = @SmsTypeId
			ORDER BY IsValid DESC ;

			IF @AnotherRecordId IS NOT NULL	
				IF @AnotherCostEUR >= mno.CurrencyConverter(@Cost, @Currency, 'EUR', DEFAULT) --@AnotherCost >= @Cost
					SET @ErrorCode += 'OperatorDuplicate,' ;
				ELSE IF @IsValid = 1 -- @AnotherCostEUR < @CurrentCostEUR and the other record is valid, deactivate the other record
					BEGIN
						UPDATE map.SupplierCostUploaderFileData
						SET IsValid = 0, ErrorCode = IIF(LEN(ErrorCode)=0, '', ',') + 'OperatorDuplicate'
						WHERE RecordId = @AnotherRecordId ;

						UPDATE map.SupplierCostUploaderFile
						SET ItemsError = ISNULL(ItemsError, 0) + 1
						WHERE FileId = @FileId ;
					END
		END ;

	IF LEN(@ErrorCode) = 0 -- continue if there's no ridiculous error & no duplicates
		IF EXISTS ( -- same cost as current
			SELECT 1 
			FROM rt.SupplierCostCoverage c
			WHERE c.RouteUid = @ConnUid
					AND c.Country = @Country
					AND ISNULL(c.OperatorId, 0) = @OperatorId
					AND c.Deleted = 1 - @Active
					AND c.EffectiveFrom < SYSUTCDATETIME()
					AND c.SmsTypeId = @SmsTypeId
					AND ((@Active = 1
						AND c.CostLocalCurrency = @Currency
						AND c.CostLocal = @Cost) OR @Active = 0))
			SET @ErrorCode += 'NoChanges,' ;

	-- summary
	IF (LEN(@ErrorCode) > 0) SET @IsValid = 0 ELSE SET @IsValid = 1 ;

	SET @ErrorCode = IIF(RIGHT(@ErrorCode,1) = ',', LEFT(@ErrorCode, LEN(@ErrorCode)-1), @ErrorCode) ; --remove the last comma

	-- main insert
	INSERT INTO map.SupplierCostUploaderFileData
		(FileId, IsValid, ConnId, ConnUid, 
		MCC, MNC, Country, OperatorId, 
		SmsType, SmsTypeId, 
		Cost, Currency, 
		EffectiveFrom, 
		Active, ErrorCode)
	OUTPUT inserted.RecordId, inserted.FileId, inserted.IsValid, inserted.ConnId,
			inserted.MCC, inserted.MNC, inserted.Country, inserted.OperatorId,
			inserted.Currency, inserted.Cost, inserted.Active, inserted.ErrorCode
	VALUES (@FileId, @IsValid, @ConnId, @ConnUid, 
		@MCC, @MNC, @Country, @OperatorId,
		@SmsType, @SmsTypeId,
		@Cost, UPPER(@Currency),
		@EffectiveFrom,
		@Active, @ErrorCode) ;

	-- update count of errors
	IF @IsValid = 0
		UPDATE map.SupplierCostUploaderFile 
		SET ItemsError = ISNULL(ItemsError, 0) + 1
		WHERE FileId = @FileId ;

END
