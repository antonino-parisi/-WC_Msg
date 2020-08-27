
-- =============================================
-- Author:		Raju Gupta
-- Create date: 11-07-2014
-- Description:	return the price corresponding to a MSISDN( For CP Websender)
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAvgPriceByMSISDN]  
--@ACCOUNTID AS NVARCHAR(50),
--@SUBACCOUNTID AS NVARCHAR(50),
@MSISDN varchar(50)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   declare @CountryName as nvarchar(50)
         --  @prefix as nvarchar(50)
         
--set @CountryName='France'
	DECLARE @ACCOUNTID AS NVARCHAR(50)
	DECLARE @SUBACCOUNTID AS NVARCHAR(50)
	SELECT @ACCOUNTID=AccountId, @SUBACCOUNTID=SubAccountId from StandardAccount WHERE StandardRouteIdName='Standard_CP_STD'    --WHERE StandardRouteIdName='Standard_1'
	--print @ACCOUNTID
	--print @SUBACCOUNTID
	
	--SELECT @prefix=SUBSTRING(@MSISDN, 1, 3);
	
	if exists(Select * from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 3))
	begin
	
	select @CountryName=Country from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 3)
	
	SELECT Avg(PR.Price) as Price FROM Operator OP 
	INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
	 WHERE OP.Country=@CountryName and PR.AccountId=@ACCOUNTID AND PR.SubAccountId=@SUBACCOUNTID
	
	end
	
	
	else if exists(Select * from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 2))
	begin
	
	select @CountryName=Country from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 2)
	
	SELECT Avg(PR.Price) as Price FROM Operator OP 
	INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
	 WHERE OP.Country=@CountryName and PR.AccountId=@ACCOUNTID AND PR.SubAccountId=@SUBACCOUNTID
	
	end
 



else if exists(Select * from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 1))
	begin
	
	select @CountryName=Country from NumberingPlan where CountryCode=SUBSTRING(@MSISDN, 1, 1)
	
	SELECT Avg(PR.Price) as Price FROM Operator OP 
	INNER JOIN PlanRoutingFor_GlobalPricing PR ON OP.OperatorId=PR.Operator
	 WHERE OP.Country=@CountryName and PR.AccountId=@ACCOUNTID AND PR.SubAccountId=@SUBACCOUNTID
	
	end
END



