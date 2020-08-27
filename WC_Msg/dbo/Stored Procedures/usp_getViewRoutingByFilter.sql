-- =============================================
-- Author:		<Raju,Gupta>
-- Create date: <Create Date,03032015,>
-- Description:	return the Plan routing data based on filters
-- =============================================
CREATE PROCEDURE [dbo].[usp_getViewRoutingByFilter]  
@AccountId NVARCHAR(50),
@RouteId NVARCHAR(50),
@Prefix NVARCHAR(50),
@Operator nvarchar(50),
@Country nvarchar(50),
@SubAccountId NVARCHAR(50)

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--if(@Prefix='%')
	--begin
SELECT AccountId, Active, Operator, Prefix, Price,Cost, Priority, RouteId, SubAccountId,CONVERT(bit,ISNULL(RoutingMode,0)) RoutingMode FROM PlanRouting 
WHERE (AccountId = @AccountId OR @AccountId = 'All')
AND (SubAccountId = @SubAccountId OR @SubAccountId = 'All')
 AND (RouteId= @RouteId OR @RouteId = 'All')
 AND (Operator= @Operator OR @Operator = 'All')  
 AND (Operator in (Select OperatorID from Operator where (Country=@Country OR (@Country = 'Kazakhstan' AND Country = 'Russia'))) OR @Country = 'All')  
 --AND(Prefix LIKE @Prefix)
  union
-- or Operator in (Select OperatorID from Operator where Operatorname=@Operator))ORDER BY Priority DESC
--end
--else
--begin
SELECT AccountId, Active, Operator, Prefix, Price,Cost, Priority, RouteId, SubAccountId,CONVERT(bit,ISNULL(RoutingMode,0)) RoutingMode FROM PlanRouting 
WHERE (AccountId = @AccountId OR @AccountId = 'All')
AND (SubAccountId = @SubAccountId OR @SubAccountId = 'All')
 AND (RouteId= @RouteId OR @RouteId = 'All')
 AND (Operator= @Operator OR @Operator = 'All')  
 --OR (Operator in (Select OperatorID from Operator where Country=@Country) OR @Country = 'All')  
 AND (Prefix LIKE @Prefix)
  
-- or Operator in (Select OperatorID from Operator where Operatorname=@Operator))ORDER BY Priority DESC
--end
END
