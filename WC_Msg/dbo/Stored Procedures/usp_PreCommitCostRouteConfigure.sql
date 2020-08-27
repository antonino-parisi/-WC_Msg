-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,07-01-2013,>
-- Description:	<Update/commit cost and Route to Plan routing table>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PreCommitCostRouteConfigure]
	-- Add the parameters for the stored procedure here		
		@SessionId NVARCHAR(250)				
AS
BEGIN
	
	
	DECLARE  @_accId NVARCHAR(50),@_subAccId NVARCHAR(50),@_opid NVARCHAR(200),@_price float,@_cost float,@_rouId NVARCHAR(50),@_proprouteId NVARCHAR(50) 
			
	SET NOCOUNT ON;
			 				
	--1 --Updateing proposed route and cost before commit all 
	-- ALTER TABLE    [dbo].[PlanRouting]  DISABLE TRIGGER [updateServer_PlanRouting]
			
	DECLARE Cost_Cursor CURSOR FOR
	select AccountId,SubAccountId,routeId,operator,ProposedRouteId,cost,price From [CostSessionData] CD 
	Where CD.SessionId=@SessionId AND CD.impact='Yes' AND CD.cost IS NOT NULL AND CD.Price IS NOT NULL AND CD.ProposedRouteId IS NOT NULL 
	OPEN Cost_Cursor
	FETCH NEXT FROM Cost_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid,@_proprouteId,@_cost,@_price
	WHILE @@FETCH_STATUS = 0
	BEGIN			
	
	
	if(	(@_price is not null) AND (@_cost is not null))
	--if(@_cost is not null)   ---1
	BEGIN		      		      		      
		      if(@_proprouteId is not null)     ---2
		       Begin
						
				Update planrouting SET Cost=ROUND(@_cost,4),RouteId=@_proprouteId where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId --and Active=1										
							
		END  ---2
																	
													
	 
	END  ---1
	
	  SET @_cost=null
	  SET @_price=null
	FETCH NEXT FROM Cost_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid,@_proprouteId,@_cost,@_price
	END
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor
	
 --	EXECUTE  sp_configurationChanged;
 --   delete from PlanRoutingFor_GlobalPricing
 --   insert into PlanRoutingFor_GlobalPricing select * from PlanRouting
 --	  ALTER TABLE    [dbo].[PlanRouting]  ENABLE TRIGGER [updateServer_PlanRouting]

	END
	
	
	
	
	
	
	
	