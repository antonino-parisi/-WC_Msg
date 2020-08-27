-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,27-11-2014,>
-- Description:	<Description,get cost for fixed routeid>
-- =============================================
-- exec usp_GetBestFixedRoutecost @OperatorId=N'204002',@AccountId=N'minisite',@SubAccountId=N'minisite_sub',@RouteId=N'Silverstreet_Direct'
CREATE PROCEDURE [dbo].[usp_GetBestFixedRoutecost]
		
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

---checking blocked routes
if exists(select * from StandardAccount where AccountId=@AccountId and SubAccountId=@SubAccountId)
begin
	SELECT @Blockroute=BlockedRoutes 
	from StandardAccount 
	where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null
end
else
begin
	SELECT @Blockroute=BlockedRoutes 
	from Account 
	where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null
end


--if blocked routes configured for accountid and subaccountid
if(@Blockroute<>'') --1
begin
	if Exists(
		SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId
		from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
		where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N',')))  --2
	begin
		--print 'Blocked1'
		SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId
		from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
		where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 and cst.RouteId not in ( SELECT REPLACE(Item, '''', '') FROM dbo.SplitStrings_XML( @Blockroute, N',')) 
	end  --2
	else
	begin --3
		set @sql=N'SELECT @MinCost=MIN(Cost) FROM CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId WHERE cst.RouteId not in ('+ @Blockroute+') and Operator' + '=@v' +' AND ccn.Active=1 AND cst.Active=1'
		EXEC sp_executesql @sql, N'@v NVARCHAR(200),@MinCost decimal(18,5) output', @OperatorId,@MinCost output
		set @sql =N'SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.RouteId not in ('+@Blockroute+') AND Operator' + ' =@v' +' AND Cost' + ' =@c' +' AND ccn.Active=1 AND cst.Active=1'
		EXEC sp_executesql @sql, N'@v NVARCHAR(200),@c decimal(18,5)', @OperatorId,@MinCost
		--print 'Blocked2'
	end --3
end --1

---if blocked routes 
Else
begin

	--SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
	--where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 

	if Exists(
		SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId
		from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
		where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 )  --2
	begin
		SELECT ROUND(Cost,4) as ProposedCost,cst.RouteId as ProposedRouteId
		from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
		where cst.Operator=@OperatorId AND cst.RouteId=@RouteId AND ccn.Active=1 AND cst.active=1 
	--print 'Non Blocked1'
	end 
	else
	begin

		SELECT @MinCost=MIN(Cost) 
		FROM CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId 
		WHERE  Operator=@OperatorId AND ccn.Active=1 AND cst.Active=1
		
		SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId
		from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId
		where Operator=@OperatorId AND Cost =@MinCost AND ccn.Active=1 AND cst.Active=1

		--print 'Non Blocked2'
		--set @sql=N'SELECT @MinCost=MIN(Cost) FROM CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId WHERE cst.RouteId not in ('+ @Blockroute+') and Operator' + '=@v' +' AND ccn.Active=1 AND cst.Active=1'
		--EXEC sp_executesql @sql, N'@v NVARCHAR(200),@MinCost decimal(18,5) output', @OperatorId,@MinCost output
		--set @sql =N'SELECT top 1 Cost as ProposedCost,cst.RouteId as ProposedRouteId  from CPCOST cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId where cst.RouteId not in ('+@Blockroute+') AND Operator' + ' =@v' +' AND Cost' + ' =@c' +' AND ccn.Active=1 AND cst.Active=1'
		--EXEC sp_executesql @sql, N'@v NVARCHAR(200),@c decimal(18,5)', @OperatorId,@MinCost
	end

end
END








