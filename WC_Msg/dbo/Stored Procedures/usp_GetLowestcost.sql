-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,25-10-2013,>
-- Description:	<Description,lOWEST COST FROM NEW COST TABLE>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLowestcost]
		
   @OperatorId nvarchar(50)
  -- @AccountId NVARCHAR(50),
   --@SubAccountId NVARCHAR(50)
  -- @RouteId   nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MinCost decimal(18,5)
   SELECT @MinCost=MIN(Cost) FROM CPCOST WHERE Operator=@OperatorId  AND ACTIVE=1
 --   AND RouteId not in(select BlockedRoutes from Account where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null )
    
  select top 1 Cost as ProposedCost,RouteId as ProposedRouteId  from CPCOST  WHERE Operator=@OperatorId and Cost= @MinCost AND ACTIVE=1
 --   AND RouteId not in(select BlockedRoutes from Account where AccountId=@AccountId AND SubAccountId=@SubAccountId and BlockedRoutes is not null )
  
   
END


