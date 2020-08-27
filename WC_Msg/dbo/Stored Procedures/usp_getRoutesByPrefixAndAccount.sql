-- =============================================
-- Author:		<Raju,Gupta>
-- Create date: <Create Date,25082014,>
-- Description:	return the Plan routing data based on filters
-- =============================================
CREATE PROCEDURE [dbo].[usp_getRoutesByPrefixAndAccount]  
@AccountId NVARCHAR(50),
@RouteId NVARCHAR(50),
@Prefix NVARCHAR(50),
@Operator nvarchar(200)


	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT AccountId, Active, Operator, Prefix, Price,Cost, Priority, RouteId, SubAccountId FROM PlanRouting 
WHERE (AccountId = @AccountId OR @AccountId = 'All')
 AND (RouteId= @RouteId OR @RouteId = 'All') 
 AND (Prefix LIKE @Prefix) AND ( @Operator = 'All' 
 or Operator in (Select OperatorID from Operator where Operatorname=@Operator))ORDER BY Priority DESC
END
