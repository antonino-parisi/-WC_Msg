-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,10-04-2013,>
-- Description:	<Update/commit cost and price to Plan routing table>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommitCostPricetoRouting]
	-- Add the parameters for the stored procedure here		
		@SessionId NVARCHAR(250)				
AS
BEGIN
	
	
	DECLARE  @_accId NVARCHAR(50),@_subAccId NVARCHAR(50),@_opid NVARCHAR(200),@_price float,@_cost float,@_rouId NVARCHAR(50) 
	 ---proposed routeid
	DECLARE @_proprouteId NVARCHAR(50),@CurrentActive bit	 
			
	DECLARE @OLDPRICE float,@NEWPRICE float
	DECLARE @EXTCOST float
	--DECLARE @RCount int
	
	SET NOCOUNT ON;
		 				
    --ALTER TABLE [dbo].[PlanRouting]  DISABLE TRIGGER [updateServer_PlanRouting]
	--1 --Updateing latest cost and price
			
	DECLARE price_Cursor CURSOR FOR
	--updated below query and now selecting distinct rows from all the committed session and processing 
	select distinct AccountId,SubAccountId,routeId,operator From [CostSessionData] CD inner join CostSession CS on CD.SessionId=CS.SessionId  Where CD.impact='Yes' and CS.Status=2     --CD.SessionId=@SessionId AND --AND CD.Price IS NOT NULL  --AND CD.cost IS NOT NULL
	OPEN price_Cursor
	FETCH NEXT FROM price_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	WHILE @@FETCH_STATUS = 0
	BEGIN			
	
	select top 1 @_price=CSD.price,@_cost=CSD.cost,@_proprouteId=CSD.ProposedRouteId,@EXTCOST=CSD.Currentcost,@CurrentActive=CSD.CurrentActive from CostSessionData CSD inner join CostSession CS on CSD.SessionId=CS.SessionId 
	where CSD.AccountId=@_accId AND CSD.SubAccountId=@_subAccId AND CSD.Operator=@_opid AND CSD.RouteId=@_rouId AND CSD.impact='Yes'     --AND CSD.Price is not null AND CSD.Price<>0
	AND CS.Status=2 
	order by CSD.DateTimeUpdated desc		
	
	--selecting old price for notification
	Select @OLDPRICE=price from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid  --and Active=1	--AND RouteId=@_rouId		
	
	if(	(@_price is not null) AND (@_cost is not null))   ---1
	BEGIN		      		      		      
		      if(@_proprouteId is not null)     ---2
		       Begin
				if exists(Select * from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId)
				BEGIN
				
				--Select @OLDPRICE=price from planrouting  where AccountId=@_accountId2 AND SubAccountId=@_subAccountId2 AND Operator=@_opid1 AND RouteId=@_proprouteId and Active=1			
				Update planrouting SET Price=ROUND(@_price,4),Active=1 where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId --and Active=1										
				--,Cost=ROUND(@_cost,4)
				--inserting price for alert
				SET @NEWPRICE=ROUND(@_price,4)
				 if(@OLDPRICE<>@NEWPRICE)
				 BEGIN
				--if alert info already save in case of multiple files commit at same time
				
				if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_proprouteId and Active=1)
				begin
				Insert into PriceChangeAlertData 
				select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
				where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId and Active=1
				end
				
				
				
				SET @OLDPRICE=null
				SET @NEWPRICE=null
				END	
											
				END
				ELSE
					BEGIN
				--Select @OLDPRICE=price from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1			
				--deleting existing route 
				DELETE from  planrouting where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid  --AND RouteId=@_rouId --and Active=1									
				
				--insert new proposed route
				INSERT INTO [dbo].[planrouting]
					   ([AccountId]
					   ,[SubAccountId]
					   ,[Prefix]
					   ,[RouteId]
					   ,[Price]
					   ,[Priority]
					   ,[Active]
					   ,[Operator]
					   ,[TariffRoute]
					   ,[Cost])
				 VALUES
					   (@_accId
					   ,@_subAccId
					   ,'none'
					   ,@_proprouteId
					   ,ROUND(@_price,4)
					   ,20
					   ,1
					   ,@_opid
					   ,0
					   ,ROUND(@_cost,4))
				
				--inserting price for alert
				SET @NEWPRICE=ROUND(@_price,4)
				 if(@OLDPRICE<>@NEWPRICE)
				 BEGIN
				 	if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_proprouteId and Active=1)
				begin
				Insert into PriceChangeAlertData 
				select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
				where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId and Active=1
				end
				
				
				SET @OLDPRICE=null
				SET @NEWPRICE=null
				END	
				
			   
				END
		
		END  ---2
																	
													
	 
	END  ---1
	
	ELSE IF((@_proprouteId is null )AND(@_price is NOT null) AND (@_cost is null))
		
		BEGIN
		 Update planrouting SET Price=ROUND(@_price,4),Active=1 where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId --and Active=1										
		
		    --inserting price for alert
		    SET @NEWPRICE=ROUND(@_price,4)
				 if(@OLDPRICE<>@NEWPRICE)
			 BEGIN
			 
			 	if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_rouId and Active=1)
				begin
				Insert into PriceChangeAlertData 
				select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost 
				from planrouting where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1
			end
			    SET @OLDPRICE=null
				SET @NEWPRICE=null
			END	
		
		END
		
	--now we're not proposing new route if cost is same as existing cost so in this case proposed section will be blank so we need to check current active for route removal
	--for route removal showing no reach in email body
	ELSE IF((@_proprouteId is null )AND(@_price is null) AND (@_cost is null) AND @CurrentActive=0)
		
		BEGIN
		-- Update planrouting SET Price=ROUND(@_price,4)where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1										
		
		    --inserting price for alert
		  --  SET @NEWPRICE=ROUND(@_price,4)
				-- if(@OLDPRICE<>@NEWPRICE)
				-- BEGIN
				
					if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_rouId and Active=1)
				begin
				Insert into PriceChangeAlertData select AccountId,SubAccountId,RouteId,@OLDPRICE,ROUND(@_price,4),Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
				where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1
			    
			    end
			    SET @OLDPRICE=null
				SET @NEWPRICE=null
				--END	
				--deactivate rows in planrouting table  -15082014
		        --Update planrouting SET Active=0 where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1	
		        
		        --We connot keep rows in planrouting due to primary key vioilation ---deleting rows from planrouting table -17092014
		        delete from  planrouting where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId 
		END
			
	
	  SET @_price=null
	  SET @_cost=null
	FETCH NEXT FROM price_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	END
	CLOSE price_Cursor
	DEALLOCATE price_Cursor
	
	
	--EXECUTE  sp_configurationChanged;
 --   delete from PlanRoutingFor_GlobalPricing
 --   insert into PlanRoutingFor_GlobalPricing select * from PlanRouting
	--ALTER TABLE [dbo].[PlanRouting]  ENABLE TRIGGER [updateServer_PlanRouting]
	
	--Update CostSession SET Status=-1 where Status=2
	--Update RouteSelSessionData SET Status=-1 where Status=2
	END
