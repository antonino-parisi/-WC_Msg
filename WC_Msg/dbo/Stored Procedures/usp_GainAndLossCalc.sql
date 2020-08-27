-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,20-05-2014,>
-- Description:	<Cost Provisioning/volumes based Gain/Loss>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GainAndLossCalc]
	-- Add the parameters for the stored procedure here		
		--@SessionId NVARCHAR(250)				
AS
BEGIN
	
	
	DECLARE  @_accId NVARCHAR(50),@_subAccId NVARCHAR(50),@_opid NVARCHAR(200),@_price float,@_cost float,@_rouId NVARCHAR(50) 
	 ---proposed routeid
	DECLARE @_proprouteId NVARCHAR(50)	 
			
	DECLARE @OLDPRICE float,@NEWPRICE float
	DECLARE @EXTCOST float
	
	
  DECLARE @TOTALVALUME AS BIGINT
  DECLARE @CALC1 decimal(25,2),@CALC2 decimal(25,2)
         Declare
           @CurrentHourlyMarginLoss decimal(25,2),
	      @CurrentHourlyMarginGain decimal(25,2),
	       @PotentialHourlyMarginLoss decimal(25,2),
	      @PotentialHourlyMarginGain decimal(25,2)
  
  
  
  declare @Startime datetime,@Endtime datetime
  set @Endtime=GETDATE()
  set @Startime=DATEADD(HOUR, -1, @Endtime)
  
	SET NOCOUNT ON;
	
	
	
	
	CREATE TABLE #TEMPTABLE_Gainlosscalc
	(
	      Accountid nvarchar(50),
	      Subaccountid nvarchar(50),
	      Routeid nvarchar(50),
	      Opid varchar(50),
	      CurrentHourlyMarginLoss decimal(25,2),
	      CurrentHourlyMarginGain decimal(25,2),
	      PotentialHourlyMarginLoss decimal(25,2),
	      PotentialHourlyMarginGain decimal(25,2)
	      
	     
	)

		 				
	--1 --Updateing latest cost and price
			
	DECLARE price_Cursor CURSOR FOR
	select AccountId,SubAccountId,routeId,operator From [CostSessionData] CD inner join CostSession CS on CD.SessionId=CS.SessionId  Where  CD.impact='Yes' AND CS.Status=2   order by CD.DateTimeUpdated desc	    --AND CD.Price IS NOT NULL  --AND CD.cost IS NOT NULL
	OPEN price_Cursor
	FETCH NEXT FROM price_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	WHILE @@FETCH_STATUS = 0
	BEGIN			
	
	
	select top 1 @_price=CSD.price,@_cost=CSD.cost,@_proprouteId=CSD.ProposedRouteId,@EXTCOST=CSD.Currentcost from CostSessionData CSD inner join CostSession CS on CSD.SessionId=CS.SessionId 
	where CSD.AccountId=@_accId AND CSD.SubAccountId=@_subAccId AND CSD.Operator=@_opid AND CSD.RouteId=@_rouId AND CSD.impact='Yes'     --AND CSD.Price is not null AND CSD.Price<>0
	AND CS.Status=2 order by CSD.DateTimeUpdated desc		


     SELECT @TOTALVALUME=COUNT(*) FROM TrafficRecord WHERE  OperatorId=@_opid and SubAccountId=@_subAccId and RouteIdUsed=@_rouId   and DateTimeStamp between @Startime  and @Endtime

--selecting old price for notification
	Select @OLDPRICE=price from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid  and Active=1	--AND RouteId=@_rouId		

--if((@_price is NOT null) AND (@_cost is not null))
--begin
     --set @CALC1=isnull(@TOTALVALUME*(isnull(@OLDPRICE,0)-isnull(@_cost,0)),0)

     --set @CALC2=isnull(@TOTALVALUME*(isnull(@_price,0)-isnull(@_cost,0)),0)
     
      set @CALC1=isnull(@TOTALVALUME,0)*(isnull(@OLDPRICE,0)-isnull(@_cost,0))

       if(@_price is NOT null)
       begin
     set @CALC2=isnull(@TOTALVALUME,0)*(isnull(@_price,0)-isnull(@_cost,0))
     end
    if(@CALC1<0)
    begin
   set @CurrentHourlyMarginLoss=@CALC1
    end
    

   if(@CALC1>0)
    begin
   set @CurrentHourlyMarginGain=@CALC1
    end



if(@CALC2<0)
    begin
   set @PotentialHourlyMarginLoss=@CALC2
    end
    

   if(@CALC2>0)
    begin
   set @PotentialHourlyMarginGain=@CALC2
    end


 delete from #TEMPTABLE_Gainlosscalc where Accountid=@_accId and Subaccountid=@_subAccId and Opid=@_opid and Routeid=@_rouId
insert into #TEMPTABLE_Gainlosscalc values(@_accId,@_subAccId,@_rouId,@_opid,@CurrentHourlyMarginLoss,@CurrentHourlyMarginGain,@PotentialHourlyMarginLoss,@PotentialHourlyMarginGain)

set @CurrentHourlyMarginLoss=null
set @CurrentHourlyMarginGain=null
set @PotentialHourlyMarginLoss=null
set @PotentialHourlyMarginGain=null
	
--select @CurrentHourlyMarginLoss as currrenthourlyloss,@CurrentHourlyMarginGain as currenthourlygain,@PotentialHourlyMarginLoss as potentialhourlyloss,@PotentialHourlyMarginGain as potentialhourlygain
	
	--if(	(@_price is not null) AND (@_cost is not null))   ---1
	--BEGIN		      		      		      
	--	      if(@_proprouteId is not null)     ---2
	--	       Begin
	--			if exists(Select * from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId)
	--			BEGIN
				
	--			--Select @OLDPRICE=price from planrouting  where AccountId=@_accountId2 AND SubAccountId=@_subAccountId2 AND Operator=@_opid1 AND RouteId=@_proprouteId and Active=1			
	--			Update planrouting SET Price=ROUND(@_price,4) where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId and Active=1										
	--			--,Cost=ROUND(@_cost,4)
	--			--inserting price for alert
	--			SET @NEWPRICE=ROUND(@_price,4)
	--			 if(@OLDPRICE<>@NEWPRICE)
	--			 BEGIN
	--			--if alert info already save in case of multiple files commit at same time
				
	--			if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_proprouteId and Active=1)
	--			begin
	--			Insert into PriceChangeAlertData 
	--			select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
	--			where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId and Active=1
	--			end
				
				
				
	--			SET @OLDPRICE=null
	--			SET @NEWPRICE=null
	--			END	
											
	--			END
	--			ELSE
	--				BEGIN
	--			--Select @OLDPRICE=price from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1			
	--			--deleting existing route 
	--			DELETE from  planrouting where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1									
				
	--			--insert new proposed route
	--			INSERT INTO [dbo].[planrouting]
	--				   ([AccountId]
	--				   ,[SubAccountId]
	--				   ,[Prefix]
	--				   ,[RouteId]
	--				   ,[Price]
	--				   ,[Priority]
	--				   ,[Active]
	--				   ,[Operator]
	--				   ,[TariffRoute]
	--				   ,[Cost])
	--			 VALUES
	--				   (@_accId
	--				   ,@_subAccId
	--				   ,'none'
	--				   ,@_proprouteId
	--				   ,ROUND(@_price,4)
	--				   ,20
	--				   ,1
	--				   ,@_opid
	--				   ,0
	--				   ,ROUND(@_cost,4))
				
	--			--inserting price for alert
	--			SET @NEWPRICE=ROUND(@_price,4)
	--			 if(@OLDPRICE<>@NEWPRICE)
	--			 BEGIN
	--			 	if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_proprouteId and Active=1)
	--			begin
	--			Insert into PriceChangeAlertData 
	--			select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
	--			where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_proprouteId and Active=1
	--			end
				
				
	--			SET @OLDPRICE=null
	--			SET @NEWPRICE=null
	--			END	
				
			   
	--			END
		
	--	END  ---2
																	
													
	 
	--END  ---1
	
	--ELSE IF((@_proprouteId is null )AND(@_price is NOT null) AND (@_cost is null))
		
	--	BEGIN
	--	 Update planrouting SET Price=ROUND(@_price,4)where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1										
		
	--	    --inserting price for alert
	--	    SET @NEWPRICE=ROUND(@_price,4)
	--			 if(@OLDPRICE<>@NEWPRICE)
	--		 BEGIN
			 
	--		 	if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_rouId and Active=1)
	--			begin
	--			Insert into PriceChangeAlertData 
	--			select AccountId,SubAccountId,RouteId,@OLDPRICE,Price,Active,Operator,@SessionId,@EXTCOST,@_cost 
	--			from planrouting where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1
	--		end
	--		    SET @OLDPRICE=null
	--			SET @NEWPRICE=null
	--		END	
		
	--	END
	
	
	--ELSE IF((@_proprouteId is null )AND(@_price is null) AND (@_cost is null))
		
	--	BEGIN
	--	-- Update planrouting SET Price=ROUND(@_price,4)where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1										
		
	--	    --inserting price for alert
	--	  --  SET @NEWPRICE=ROUND(@_price,4)
	--			-- if(@OLDPRICE<>@NEWPRICE)
	--			-- BEGIN
				
	--				if Not Exists(Select * from PriceChangeAlertData where AccountId= @_accId and SubAccountId=@_subAccId and Operator=@_opid AND RouteId=@_rouId and Active=1)
	--			begin
	--			Insert into PriceChangeAlertData select AccountId,SubAccountId,RouteId,@OLDPRICE,ROUND(@_price,4),Active,Operator,@SessionId,@EXTCOST,@_cost from planrouting 
	--			where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1
			    
	--		    end
	--		    --SET @OLDPRICE=null
	--			--SET @NEWPRICE=null
	--			--END	
		
	--	END
			
	
	--  SET @_price=null
	--  SET @_cost=null
	--end
	FETCH NEXT FROM price_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	END
	CLOSE price_Cursor
	DEALLOCATE price_Cursor
	
	select * from #TEMPTABLE_Gainlosscalc
	
	--select SUM(isnull(CurrentHourlyMarginLoss,0) + isnull(CurrentHourlyMarginGain,0)+ isnull(PotentialHourlyMarginLoss,0) + isnull(PotentialHourlyMarginGain,0)) Total from #TEMPTABLE_Gainlosscalc
	
	select SUM(isnull(CurrentHourlyMarginLoss,0)) TotalCurrentHourlyMarginLoss,
	 SUM(isnull(CurrentHourlyMarginGain,0)) TotalCurrentHourlyMarginGain,
	 SUM(isnull(PotentialHourlyMarginLoss,0)) TotalPotentialHourlyMarginLoss
	,SUM(isnull(PotentialHourlyMarginGain,0))  TotalPotentialHourlyMarginGain from #TEMPTABLE_Gainlosscalc
	
	drop table #TEMPTABLE_Gainlosscalc
	END
	
	
	
	
	
	
	
	