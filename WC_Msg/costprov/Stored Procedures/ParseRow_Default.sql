
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-10
-- Description:	CostProvisioning process / Default parser for records
-- =============================================
-- Examples
-- EXEC costprov.ParseRow_Default @PacketId='7CC36CB2-8F30-4BC2-BDD9-6EAB28B9A034', @ParserId='Beepsend', @RouteKeyword='Wavecell04', @MCC=248, @MNC=1, @Currency='EUR', @OldCost=0.0333, @NewCost=0.03393, @EffectiveTimeUtc='10.06.2016 00:00'
-- =============================================
CREATE PROCEDURE [costprov].[ParseRow_Default] (
	@PacketId uniqueidentifier,
	@ParserId varchar(50),
	@RouteKeyword varchar(50),
	@MCC smallint,
	@MNC smallint,
	@Currency varchar(3),
	@OldCost real = NULL,
	@NewCost real,
	@RouteStatus char(1) = NULL,
	@EffectiveTimeUtc datetime = NULL
)
AS
BEGIN

	DECLARE @RouteId varchar(50)
	DECLARE @Error NVARCHAR(2048)
	DECLARE @OperatorId int

	-- Define Currency
	IF (@Currency <> 'EUR')
	BEGIN
		SET @Error = CONCAT('Unsupported currency=', @Currency);
		THROW 51000, @Error, 1;
	END
	
	-- Define RouteId
	SELECT @RouteId = RouteId FROM costprov.RouteLookup WHERE ParserId = @ParserId AND RouteKeyword = @RouteKeyword
	IF @RouteId IS NULL 
	BEGIN
		SET @Error = CONCAT('Can not find ''RouteId'' for ParserId=', @ParserId, ' and RouteKeyword=', @RouteKeyword);
		THROW 51000, @Error, 1;
	END

	-- Define OperatorId
	SELECT @OperatorId = OperatorId FROM mno.OperatorIdLookup WHERE MCC = @MCC AND MNC = @MNC
	IF @OperatorId IS NULL
	BEGIN
		SET @Error = CONCAT('OperatorId not found for MCC=', @MCC, ' and MNC=', @MNC);
		THROW 51000, @Error, 1;
	END

	-- Set @EffectiveTimeUtc
	IF (@EffectiveTimeUtc IS NULL) SET @EffectiveTimeUtc = GETUTCDATE()

	--Result
	INSERT INTO costprov.PriceChangeLog ([PacketId],[RouteId],[MCC],[MNC],[OperatorId],[Currency],[NewCost],[RouteStatus],EffectiveTimeUtc,[Comments])
	VALUES (@PacketId, @RouteId, @MCC, @MNC, @OperatorId, @Currency, @NewCost, @RouteStatus, @EffectiveTimeUtc, NULL)

	SELECT @RouteId AS RouteId, @OperatorId AS OperatorId, @MCC AS MCC, @MNC AS MNC, @Currency AS Currency, CAST(@NewCost AS decimal(10,6)) AS NewCost, @EffectiveTimeUtc AS EffectiveTimeUtc, @RouteStatus AS RouteStatus

END

