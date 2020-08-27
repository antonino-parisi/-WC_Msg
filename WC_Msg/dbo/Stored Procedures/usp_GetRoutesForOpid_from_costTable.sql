
-- =============================================
-- Author:		Raju Gupta
-- Create date: 25/10/2013
-- Description:	return the routes corresponding to a operatorid from cost table
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRoutesForOpid_from_costTable]  
@Operator NVARCHAR(200),
@AccountId NVARCHAR(50),
@SubAccountId NVARCHAR(50)

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
Declare @Blockroute nvarchar(max)
declare @sql nvarchar(max)

if exists(select * from StandardAccount where AccountId=@AccountId and SubAccountId=@SubAccountId)
 begin
 SELECT @Blockroute=BlockedRoutes from StandardAccount where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null
 end
 else
begin
SELECT @Blockroute=BlockedRoutes from Account where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null
end
if @Blockroute<>''
begin
set @sql =N'SELECT  cst.RouteId,cst.Cost FROM cpcost cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId  WHERE  cst.RouteId not in ('+@Blockroute+') AND cst.Operator' + ' =@v' +' AND ccn.Active=1'+ 'AND cst.ACTIVE=1' +' order by cost asc'
EXEC sp_executesql @sql, N'@v NVARCHAR(200)', @Operator;
end
else 
SELECT cst.RouteId,cst.Cost FROM cpcost cst inner join CarrierConnections ccn on cst.RouteId=ccn.RouteId  WHERE  cst.Operator=@Operator AND ccn.Active=1 AND cst.Active=1 order by cost asc

END


