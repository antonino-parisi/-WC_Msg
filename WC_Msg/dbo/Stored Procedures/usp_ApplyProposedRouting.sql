-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,08-11-2013,>
-- Description:	<Apply propose routing on live routing table from view routing page>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ApplyProposedRouting]
	-- Add the parameters for the stored procedure here		
			 @_accountId NVARCHAR(50)
			 ,@_subAccountId NVARCHAR(50)
			 ,@_operator NVARCHAR(200)	
			 ,@_liverouteId NVARCHAR(50)
			 ,@_proprouteId NVARCHAR(50)
			 ,@_price float
			 ,@_cost float
			 ,@_outproprouteId NVARCHAR(50) Output
			 ,@_outprice float output
			 ,@_outcost float output
			 
			 	 
			 
AS
BEGIN
	
	
	SET NOCOUNT ON;
	
	
	--if(	(@_price is not null) AND (@_cost is not null))
	--BEGIN
		
				if exists(Select * from planrouting  where AccountId=@_accountId AND SubAccountId=@_subAccountId AND Operator=@_operator AND RouteId=@_proprouteId)
				BEGIN
				
				--Select @OLDPRICE=price from planrouting  where AccountId=@_accountId2 AND SubAccountId=@_subAccountId2 AND Operator=@_opid1 AND RouteId=@_proprouteId and Active=1			
				Update planrouting SET Price=ROUND(@_price,4),Cost=ROUND(@_cost,4) where AccountId=@_accountId AND SubAccountId=@_subAccountId AND Operator=@_operator AND RouteId=@_proprouteId and Active=1										
				END
				ELSE
					BEGIN
				--Select @OLDPRICE=price from planrouting  where AccountId=@_accId AND SubAccountId=@_subAccId AND Operator=@_opid AND RouteId=@_rouId and Active=1			
				--deleting existing route 
				DELETE from  planrouting where AccountId=@_accountId AND SubAccountId=@_subAccountId AND Operator=@_operator AND RouteId=@_liverouteId and Active=1									
				
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
					   (@_accountId
					   ,@_subAccountId
					   ,'none'
					   ,@_proprouteId
					   ,ROUND(@_price,4)
					   ,20
					   ,1
					   ,@_operator
					   ,0
					   ,ROUND(@_cost,4))
				
				END
		
	
			 
	SELECT @_outproprouteId=[RouteId],@_outprice=[Price],@_outcost=[Cost] FROM planrouting WHERE [AccountId]=@_accountId AND [SubAccountId]=@_subAccountId AND [Operator]=@_operator AND [RouteId]=@_proprouteId
	

END