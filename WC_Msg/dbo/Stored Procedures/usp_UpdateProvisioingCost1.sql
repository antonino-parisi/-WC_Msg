-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateProvisioingCost1]
@uploadCost RouteOPCOSTType READONLY,
@IsComprehnsive bit,
@NetworkType nvarchar(50)
	
AS
BEGIN
	
	declare @operator nvarchar(50)
	declare @routeid nvarchar(50)
	declare @Cost decimal(18,5)
	set rowcount 0
	select @operator = Operator,@routeid=routeid,@Cost=cost from @uploadCost
	
	--Comprhensive upload with all networks
	 	
	if(@IsComprehnsive=1 and @NetworkType='All')
	BEGIN
	UPDATE cp SET cp.Active=0
	
	DECLARE Cost_Cursor CURSOR FOR
	select routeId,operator,cost From @uploadCost 
	OPEN Cost_Cursor
	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	

	
	   IF  EXISTS(select * from CPCost where Operator = @operator and routeid=@routeid)
   begin
         
          UPDATE cp SET cp.Cost=@Cost,cp.Active=1  FROM CPCost cp
            WHERE cp.RouteId=@routeid and cp.Operator=@operator
  end
  	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	END	
	
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor			
	
	        --UPDATE cp SET cp.Active=0  FROM CPCost cp, @uploadCost d 
         --   WHERE cp.RouteId<>d.RouteId and cp.Operator<>d.Operator
	
	END
	
	END
	
	
    --- Partial upload with all networks
    	
	if(@IsComprehnsive=0 and @NetworkType='All')
	BEGIN
	DECLARE Cost_Cursor CURSOR FOR
	select routeId,operator,cost From @uploadCost 
	OPEN Cost_Cursor
	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	
	   IF  EXISTS(select * from CPCost where Operator = @operator and routeid=@routeid)
        begin
                   
          UPDATE cp SET cp.Cost=@Cost,cp.Active=1  FROM CPCost cp
            WHERE cp.RouteId=@routeid and cp.Operator=@operator
       end
   	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	END	
	
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor			
	
	        --UPDATE cp SET cp.Active=0  FROM CPCost cp, @uploadCost d 
         --   WHERE cp.RouteId<>d.RouteId and cp.Operator<>d.Operator
	
	END
	
	
	
	
	-- Comprehnsive upload for single network
	
	if(@IsComprehnsive=1 and @NetworkType='Single')
	BEGIN
	
	
	DECLARE Cost_Cursor CURSOR FOR
	select routeId,operator,cost From @uploadCost 
	OPEN Cost_Cursor
	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	

	
	   IF  EXISTS(select * from CPCost where Operator = @operator and routeid=@routeid)
   begin
         
          UPDATE cp SET cp.Cost=@Cost,cp.Active=1  FROM CPCost cp
            WHERE cp.RouteId=@routeid and cp.Operator=@operator
  end
  	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	END	
	
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor			
	
	        UPDATE cp SET cp.Active=0  FROM CPCost cp, @uploadCost d 
            WHERE cp.RouteId=d.RouteId and cp.Operator<>d.Operator
	
	END
	
	
	
	
    --- Partial upload with Single Network
    	
	if(@IsComprehnsive=0 and @NetworkType='Single')
	BEGIN
	DECLARE Cost_Cursor CURSOR FOR
	select routeId,operator,cost From @uploadCost 
	OPEN Cost_Cursor
	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	
	   IF  EXISTS(select * from CPCost where Operator = @operator and routeid=@routeid)
        begin
                   
          UPDATE cp SET cp.Cost=@Cost,cp.Active=1  FROM CPCost cp
            WHERE cp.RouteId=@routeid and cp.Operator=@operator
       end
   	
	FETCH NEXT FROM Cost_Cursor INTO @routeid,@operator,@Cost
	END	
	
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor			
	
	        --UPDATE cp SET cp.Active=0  FROM CPCost cp, @uploadCost d 
         --   WHERE cp.RouteId<>d.RouteId and cp.Operator<>d.Operator
	
	END
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--cast(d.Cost as decimal(18,5))
--	if(@IsComprehnsive=1 and @CostfileType='All Networks')
--	begin
--	while @@rowcount <> 0
--   begin  
   
--   IF  EXISTS(select * from CPCost where Operator = @operator and routeid=@routeid)
--   begin
   
--  end
   
--   else
--   begin
  
--  end
   
--   set rowcount 1 
   
--     select @operator = Operator,@routeid=routeid from @uploadCost

--end
--set rowcount 0
	
	  --update [dbo].[CPCost] set Active=1	
	  
	  --     UPDATE cp SET cp.Cost=d.Cost  FROM CPCost cp, @uploadCost d 
   --         WHERE cp.RouteId=d.RouteId and cp.Operator=d.Operator
   --      end
    
    
    
   --      else
   --      begin
         
   --        update [dbo].[CPCost] set Active=0
   --       UPDATE cp SET cp.Cost=d.Cost,cp.Active=1  FROM CPCost cp, @uploadCost d 
   --         WHERE cp.RouteId=d.RouteId and cp.Operator=d.Operator
         
   --      end
            
	
	




