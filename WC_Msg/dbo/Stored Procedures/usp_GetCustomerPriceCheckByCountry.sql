
	-- =============================================
	-- Author:		Raju Gupta
	-- Create date: FEB-2014
	-- Description:	return the price details corresponding to a country and subaccount for CP
	-- =============================================
	CREATE PROCEDURE [dbo].[usp_GetCustomerPriceCheckByCountry]  
	@CountryName NVARCHAR(50),
	@Account NVARCHAR(50),
	@Subaccount NVARCHAR(50)


	--DECLARE
	--@CountryName NVARCHAR(50),
	--@Account NVARCHAR(50),
	--@Subaccount NVARCHAR(50)

	--set @CountryName='France'
	--set @Account='Netval1'
	--set @Subaccount='Netval3Sybase'


	AS
	BEGIN		
		CREATE TABLE #TEMPPRICE_1
		(		
			Operator nvarchar(50),
			OperatorId	nvarchar(50),	
			Price float		
		)
	        
	        
	        
		CREATE TABLE #TEMPPRICE_2
		(		
			Operator nvarchar(50),
			OperatorId	nvarchar(50),		
			Price float	
		)
	        
	        CREATE TABLE #TEMPPRICE_prefix
		(		
			Operator nvarchar(50),		
			Price float		
		)
	        
	        
	        
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
	    
		SET NOCOUNT ON;
	   --declare @CountryName as nvarchar(50)
		--set @CountryName='France'
		DECLARE @ACCOUNTID_1 AS NVARCHAR(50)
		DECLARE @SUBACCOUNTID_1 AS NVARCHAR(50)
		DECLARE @StandardRouteId AS NVARCHAR(50)
		DECLARE @Countrycode int 
		Declare @prefix nvarchar(50)
	    
	    
	    
	SELECT @StandardRouteId=StandardRouteId FROM ACCOUNT WHERE AccountId=@Account AND SubAccountId=@Subaccount 

		-- print @StandardRouteId
	set @Countrycode=(select top 1 countrycode from numberingplan where country=@CountryName)

	set @prefix=cast(@Countrycode as nvarchar(50))+'%'
	 
	

		 if exists(select * from PlanRoutingFor_GlobalPricing PR where PR.AccountId=@Account AND PR.SubAccountId=@Subaccount and (Prefix=@prefix OR Prefix='%'))
		 begin
		 --print @prefix
		 if exists(select * from PlanRoutingFor_GlobalPricing PR where PR.AccountId=@Account AND PR.SubAccountId=@Subaccount and Prefix=@prefix )
		 begin
		insert into #TEMPPRICE_prefix select 'All', PR.Price from PlanRoutingFor_GlobalPricing PR where PR.AccountId=@Account AND PR.SubAccountId=@Subaccount and Prefix=@prefix
		 end
		 else
		 begin
		 insert into #TEMPPRICE_prefix select 'All', PR.Price from PlanRoutingFor_GlobalPricing PR where PR.AccountId=@Account AND PR.SubAccountId=@Subaccount and Prefix='%'
		 end
		 		 		 		 
		 --insert into #TEMPPRICE_1 SELECT PR.RouteId, PR.Price FROM Operator OP 
		 --INNER JOIN planrouting_test_dump PR ON OP.OperatorId=PR.Operator
		 --WHERE OP.Country=@CountryName and PR.AccountId=@Account AND PR.SubAccountId=@Subaccount
	   --print 'select prefix'
	   select * from #TEMPPRICE_prefix
	   
	    end


       
	else

	begin

--print 'else part main'
		 insert into #TEMPPRICE_1 SELECT  OP.OperatorName,OP.OperatorId, PR.Price FROM Operator OP 
		 INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
		 WHERE OP.Country=@CountryName and PR.AccountId=@Account AND PR.SubAccountId=@Subaccount
	          
			  --  union all
	                    
		if(@StandardRouteId is not null)	
		begin	
		 SELECT @ACCOUNTID_1=AccountId, @SUBACCOUNTID_1=SubAccountId from StandardAccount WHERE StandardRouteIdName=@StandardRouteId	  	
	     
		 insert into #TEMPPRICE_2 SELECT OP.OperatorName,OP.OperatorId, PR.Price as Price FROM Operator OP INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
		 WHERE OP.Country=@CountryName and PR.AccountId=@ACCOUNTID_1 AND PR.SubAccountId=@SUBACCOUNTID_1 AND OP.OperatorId not in(select OperatorId from #TEMPPRICE_1)		
	    
		--print @ACCOUNTID
		--print @SUBACCOUNTID			    
	end
		select * from #TEMPPRICE_1
	union 
	select * from #TEMPPRICE_2
	
	end

	
	drop table #TEMPPRICE_1
	drop table #TEMPPRICE_2
    drop table #TEMPPRICE_prefix

	--else
	--begin
	--end


	END



