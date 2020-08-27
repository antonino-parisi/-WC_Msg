-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,25-10-2013,>
-- Description:	<Description,lOWEST COST FROM NEW COST TABLE>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLowestcost1]
		
   @OperatorId nvarchar(50),
   @AccountId NVARCHAR(50),
   @SubAccountId NVARCHAR(50)
  -- @RouteId   nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MinCost decimal(18,5)
	Declare @Blockroute nvarchar(max)
    DECLARE @sql nvarchar(max)

SELECT @Blockroute=BlockedRoutes from Account where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null

if(@Blockroute<>'')
begin
set @sql=N'SELECT @MinCost=MIN(Cost) FROM CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId WHERE cst.RouteId not in ('+ @Blockroute+') and Operator' + '=@v' +' AND ccn.Active=1'
EXEC sp_executesql @sql, N'@v NVARCHAR(200),@MinCost decimal(18,5) output', @OperatorId,@MinCost output
set @sql =N'SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.RouteId not in ('+@Blockroute+') AND Operator' + ' =@v' +' AND Cost' + ' =@c' +' AND ccn.Active=1'
EXEC sp_executesql @sql, N'@v NVARCHAR(200),@c decimal(18,5)', @OperatorId,@MinCost
end
Else
begin
SELECT @MinCost=MIN(Cost) FROM CPCOST cst  inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId  WHERE Operator=@OperatorId AND ccn.Active=1
SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.Operator=@OperatorId AND cst.Cost =@MinCost AND ccn.Active=1
end
END








