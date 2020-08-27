-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,25-10-2013,>
-- Description:	<Description,lOWEST COST FROM NEW COST TABLE>
-- =============================================
-- exec usp_GetBestcost @OperatorId=N'204002',@AccountId=N'cp_curated',@SubAccountId=N'cp_curated',@RouteId=N'Lleida_HQ'
CREATE PROCEDURE [dbo].[usp_GetBestcost]
		
   @OperatorId nvarchar(50),
   @AccountId NVARCHAR(50),
   @SubAccountId NVARCHAR(50),
   @RouteId   nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MinCost decimal(18,5)
	Declare @Blockroute nvarchar(max)
    DECLARE @sql nvarchar(max)


if exists(select * from StandardAccount where AccountId=@AccountId and SubAccountId=@SubAccountId)
 begin
 SELECT @Blockroute=BlockedRoutes from StandardAccount where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null
 end
else
begin
SELECT @Blockroute=BlockedRoutes from Account where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null

end

if(@Blockroute<>'')
begin
--set @sql=N'SELECT @MinCost=MIN(Cost) FROM CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId WHERE cst.RouteId not in ('+ @Blockroute+') and Operator' + '=@v' +' AND ccn.Active=1 AND cst.Active=1'
--EXEC sp_executesql @sql, N'@v NVARCHAR(200),@MinCost decimal(18,5) output', @OperatorId,@MinCost output
--print 'blocked routes'
SELECT @MinCost=MIN(Cost) FROM CPCOST cst  inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId  
WHERE Operator=@OperatorId AND ccn.Active=1 AND cst.Active=1 
and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N','))


if Exists(SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 
and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N','))and cst.Cost =@MinCost)  --2
begin
--print 'blocked routes exists'
SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N','))and cst.Cost =@MinCost
end  --2

else

begin

--set @sql =N'SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.RouteId not in ('+@Blockroute+') AND Operator' + ' =@v' +' AND Cost' + ' =@c' +' AND ccn.Active=1 AND cst.Active=1'
--EXEC sp_executesql @sql, N'@v NVARCHAR(200),@c decimal(18,5)', @OperatorId,@MinCost

SELECT top 1 ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from 
CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
where cst.Operator=@OperatorId AND cst.Cost =@MinCost AND ccn.Active=1 
AND cst.active=1 and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N','))
--print 'blocked routes Not exists'

end
end

Else  --Not blocked routes
begin
--print 'Non blocked routes'
SELECT @MinCost=MIN(Cost) FROM CPCOST cst  inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId  WHERE Operator=@OperatorId AND ccn.Active=1 AND cst.Active=1

if exists(SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.Operator=@OperatorId AND cst.Cost =@MinCost AND ccn.Active=1 AND cst.active=1 AND cst.RouteId=@RouteId )
begin
--print 'Non blocked routes Exists'
SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.Operator=@OperatorId AND cst.Cost =@MinCost AND ccn.Active=1 AND cst.active=1 AND cst.RouteId=@RouteId 
end

else
begin
--print 'Non blocked routes Not Exists'
SELECT top 1 ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.Operator=@OperatorId AND cst.Cost =@MinCost AND ccn.Active=1 AND cst.active=1
end
end
END
