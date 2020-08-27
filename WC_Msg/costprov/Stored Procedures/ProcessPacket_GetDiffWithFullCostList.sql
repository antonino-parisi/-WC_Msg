
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-08
-- Description:	CostProvisioning process / Get Diff from existing Cost data for requested RouteIds
-- =============================================
-- Examples
-- EXEC costprov.ProcessPacket_GetDiffWithFullCostList @PacketId='45D6C0E1-2958-4029-8C7B-0F03FF0CE341'
-- =============================================
CREATE PROCEDURE [costprov].[ProcessPacket_GetDiffWithFullCostList]
	@PacketId uniqueidentifier
AS
BEGIN

	----- Debug
	--DECLARE @PacketId uniqueidentifier
	--SET @PacketId='45D6C0E1-2958-4029-8C7B-0F03FF0CE341'

	SELECT n.RouteId, n.OperatorId, n.MCC, n.MNC, n.Currency, n.NewCost, ISNULL(n.EffectiveTimeUtc, n.CreatedTimeUtc) AS EffectiveTimeUtc, CASE WHEN o.RouteId IS NULL THEN 'A' /* new destination */ ELSE 'U' /* cost update for existing destination */ END AS RouteStatus
	FROM costprov.PriceChangeLog n
		LEFT OUTER JOIN rt.RouteOperator o ON n.RouteId = o.RouteId AND n.OperatorId = o.OperatorId
	WHERE n.PacketId = @PacketId AND (o.RouteId IS NULL OR (o.Cost <> n.NewCost OR o.Currency <> n.Currency))
	---
	UNION ALL
	SELECT o.RouteId, o.OperatorId, mno.MCC, mno.MNC, 'EUR' AS Currency, 999 AS NewCost, GETUTCDATE() AS EffectiveTimeUtc, 'R' /* remove of existing destination */ AS RouteStatus
	FROM rt.RouteOperator o 
		INNER JOIN mno.OperatorIdLookup mno ON o.OperatorId = mno.OperatorId
	WHERE 
		/* it might be a data bug if there are more than 1 RouteId inside one PacketId */
		o.RouteId IN (SELECT DISTINCT RouteId FROM costprov.PriceChangeLog n WHERE n.PacketId = @PacketId)
		AND NOT EXISTS (SELECT 1 FROM costprov.PriceChangeLog n WHERE n.PacketId = @PacketId AND n.OperatorId = o.OperatorId AND n.RouteId = o.RouteId)

END

