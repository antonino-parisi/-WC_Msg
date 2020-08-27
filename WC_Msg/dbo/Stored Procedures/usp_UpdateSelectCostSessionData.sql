-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,12-07-2013,>
-- Description:	<Update and select cost session data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateSelectCostSessionData]
	-- Add the parameters for the stored procedure here
		@SessionId NVARCHAR(250)				
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	--Comprehensive update variables
	DECLARE  @OPID NVARCHAR(200),@ROUTEID NVARCHAR(50),@OPID1 NVARCHAR(50),@ROUTEID1 NVARCHAR(200)	 
	
	SET NOCOUNT ON;




--3--<Comprehensive Update/commit cost to Plan routing table>
	
IF  EXISTS(Select * from CostSession where SessionId=@SessionId AND Iscomprehensive=1)
BEGIN	
	DECLARE Route_Cursor CURSOR FOR
	select routeId,operator From [planrouting] 
	OPEN Route_Cursor
	
	FETCH NEXT FROM Route_Cursor INTO @ROUTEID,@OPID
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	Select top 1 @ROUTEID1=SM.RouteId,@OPID1=SM.Operator from SessionMatchingOpRoute SM where SM.SessionId=@SessionId AND SM.RouteId=@ROUTEID AND SM.Operator=@OPID			
	if(	(@ROUTEID1 is not null) AND (@OPID1 is not null))
	BEGIN
	Update CostSessionData SET InCostFile='Y' where Operator=@OPID1 AND RouteId=@ROUTEID1												
		SET @ROUTEID1=null
	  SET @OPID1=null
	END
	Else
	BEGIN
	Update CostSessionData SET InCostFile='N' where Operator=@OPID AND RouteId=@ROUTEID												
	END
	FETCH NEXT FROM Route_Cursor INTO @ROUTEID,@OPID
	END	
	
	CLOSE Route_Cursor
	DEALLOCATE Route_Cursor			
	
	END



-----duplicte rows issue ---
CREATE TABLE #TEMPTABLE_CD1
(
    [AccountId] nvarchar(50) ,
	[SubAccountId] nvarchar(50),
	[RouteId] nvarchar(50),
	[Price] float,
	[Operator] nvarchar(200),
	[Cost] float,
	[Margin] float,
	[MarginPercent] float,
	[SessionId] nvarchar(250),
	[DateTime] datetime,
	[Currentcost] float,
	[Currentprice] float,
	[Currentmargin] float,
	[Currentmarginpercent] float,
	[UpdateMargin] float ,
	[UpdateMarginpercent] float,
	[Impact] nvarchar(50),
	[Active] bit,
	[CurrentActive] bit,
	[Country] nvarchar(50),
	[InCostFile] nvarchar(50),
	[DateTimeUpdated] datetime,
	[OperatorName] nvarchar(max),
	[ProposedRouteId] nvarchar(50),
	[UpdateCost] float,
	[RoutingMode] int,
	[RouteStatus] nvarchar(50)
)


CREATE TABLE #TEMPTABLE_CD2
(
    [AccountId] nvarchar(50) ,
	[SubAccountId] nvarchar(50),
	[RouteId] nvarchar(50),
	[Price] float,
	[Operator] nvarchar(200),
	[Cost] float,
	[Margin] float,
	[MarginPercent] float,
	[SessionId] nvarchar(250),
	[DateTime] datetime,
	[Currentcost] float,
	[Currentprice] float,
	[Currentmargin] float,
	[Currentmarginpercent] float,
	[UpdateMargin] float ,
	[UpdateMarginpercent] float,
	[Impact] nvarchar(50),
	[Active] bit,
	[CurrentActive] bit,
	[Country] nvarchar(50),
	[InCostFile] nvarchar(50),
	[DateTimeUpdated] datetime,
	[OperatorName] nvarchar(max),
	[ProposedRouteId] nvarchar(50),
	[UpdateCost] float,
	[RoutingMode] int,
	[RouteStatus] nvarchar(50)
)
CREATE TABLE #TEMPTABLE_CD3
(
    [AccountId] nvarchar(50),
	[SubAccountId] nvarchar(50),
    [RouteId] nvarchar(50),
	[Price] float,
	[Operator] nvarchar(200),
	[Cost] float,
	[Margin] float,
	[MarginPercent] float,
	[Currentcost] float,
	[Currentprice] float,
	[Currentmargin] float,
	[Currentmarginpercent] float,
	[Country] nvarchar(50),
	[Active] bit,
	[CurrentActive] bit,
	[UpdateMargin] float,
	[UpdateMarginpercent] float,
	
	[InCostFile] nvarchar(50),

	[OperatorName] nvarchar(max),
	[ProposedRouteId] nvarchar(50),
	[UpdateCost] float,
	[RoutingMode] int,
	[RouteStatus] nvarchar(50)
)
insert into #TEMPTABLE_CD1 select distinct CD.ACCOUNTID,CD.SUBACCOUNTID ,CD.ROUTEID,CD.PRICE ,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.SessionId,cd.DateTime,
cd.Currentcost,cd.Currentprice,cd.Currentmargin,cd.Currentmarginpercent,isnull(CD.UpdateMargin,1000000) as UpdateMargin,cd.UpdateMarginpercent,cd.Impact,cd.Active,cd.CurrentActive
,cd.Country,cd.InCostFile,cd.DateTimeUpdated,cd.OperatorName,CD.ProposedRouteId,cd.UpdateCost,cd.RoutingMode,CD.RouteStatus
 from CostSessionData  CD INNER JOIN CostSession CS  ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID=@SessionId AND CS.STATUS=1 AND CD.Impact='Yes' 

--INNER JOIN CostSession CS  ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID='All_rgupta_13/08/2014_1541301308' AND CS.STATUS=1 AND CD.Impact='Yes' 


--insert into #TEMPTABLE_CD1 SELECT CD.ACCOUNTID,CD.SUBACCOUNTID ,CD.ROUTEID,CD.PRICE ,CD.OPERATOR,CD.COST,
--CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,CD.CURRENTPRICE,CD.CURRENTMARGIN,
--CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
--CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost 
--FROM CostSessionData CD INNER JOIN CostSession CS 
--ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID='All_rgupta_13/08/2014_1541301308' AND CS.STATUS=1 AND CD.Impact='Yes'  
--group by CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,
--CD.CURRENTPRICE,CD.CURRENTMARGIN,CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000)
--,CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost  order by CD.AccountId asc


insert into #TEMPTABLE_CD2 SELECT * FROM #TEMPTABLE_CD1  where UpdateMargin<>1000000

--select * from #TEMPTABLE_CD2


DECLARE  @_accId NVARCHAR(50),@_subAccId NVARCHAR(50),@_opid NVARCHAR(200),@_rouId NVARCHAR(50)

DECLARE Cost_Cursor CURSOR FOR
	select AccountId,SubAccountId,routeId,operator From #TEMPTABLE_CD2     --AND CD.Price IS NOT NULL  --AND CD.cost IS NOT NULL
	OPEN Cost_Cursor
	FETCH NEXT FROM Cost_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	WHILE @@FETCH_STATUS = 0
	BEGIN			
	delete from #TEMPTABLE_CD1 where AccountId=@_accId and SubAccountId=@_subAccId and RouteId=@_rouId and Operator=@_opid
    --delete from CostSessionData where SessionId='All_rgupta_13/08/2014_105233866' and Impact='Yes' and AccountId=@_accId and SubAccountId=@_subAccId and RouteId=@_rouId and Operator=@_opid and UpdateMargin is null
FETCH NEXT FROM Cost_Cursor INTO @_accId,@_subAccId,@_rouId,@_opid
	END
	CLOSE Cost_Cursor
	DEALLOCATE Cost_Cursor
	
	



--select * from #TEMPTABLE_CD1
--union
--select * from #TEMPTABLE_CD2






insert into #TEMPTABLE_CD3

 SELECT CD.ACCOUNTID,CD.SUBACCOUNTID ,CD.ROUTEID,CD.PRICE ,CD.OPERATOR,CD.COST,
CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,CD.CURRENTPRICE,CD.CURRENTMARGIN,
CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost,cd.RoutingMode,CD.RouteStatus
FROM #TEMPTABLE_CD1 CD 
--INNER JOIN CostSession CS ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID='All_rgupta_13/08/2014_1541301308' AND CS.STATUS=1 AND CD.Impact='Yes'  
group by CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,
CD.CURRENTPRICE,CD.CURRENTMARGIN,CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000)
,CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost,cd.RoutingMode,CD.RouteStatus  --order by CD.AccountId asc

union 

 SELECT CD.ACCOUNTID,CD.SUBACCOUNTID ,CD.ROUTEID,CD.PRICE ,CD.OPERATOR,CD.COST,
CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,CD.CURRENTPRICE,CD.CURRENTMARGIN,
CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost,cd.RoutingMode,CD.RouteStatus
FROM #TEMPTABLE_CD2 CD 
--INNER JOIN CostSession CS ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID='All_rgupta_13/08/2014_1541301308' AND CS.STATUS=1 AND CD.Impact='Yes'  
group by CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,
CD.CURRENTPRICE,CD.CURRENTMARGIN,CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000)
,CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost,cd.RoutingMode,CD.RouteStatus  --order by CD.AccountId asc

--select * from #TEMPTABLE_CD1 group by AccountId,SubAccountId,RouteId,Operator

select * from #TEMPTABLE_CD3 order by AccountId asc

delete from CostSessionData where SessionId=@SessionId and Impact='Yes'

insert into CostSessionData select  AccountId,SubAccountId,RouteId,Price,Operator,Cost,Margin,MarginPercent,@SessionId,GETDATE(),Currentcost,Currentprice,Currentmargin,Currentmarginpercent,UpdateMargin,UpdateMarginpercent,'Yes',Active,CurrentActive,Country,InCostFile,GETDATE(),Operator,ProposedRouteId,UpdateCost,RoutingMode,RouteStatus
 from #TEMPTABLE_CD3

drop table #TEMPTABLE_CD1
drop table #TEMPTABLE_CD2
drop table #TEMPTABLE_CD3




--SELECT distinct CD.ACCOUNTID,CD.SUBACCOUNTID,CD.ROUTEID,CD.PRICE,CD.OPERATOR,CD.COST,
--CD.MARGIN,CD.MARGINPERCENT,CD.CURRENTCOST,CD.CURRENTPRICE,CD.CURRENTMARGIN,
--CD.CURRENTMARGINPERCENT,CD.COUNTRY,CD.ACTIVE,CD.CURRENTACTIVE,isnull(CD.UpdateMargin,1000000) as UpdateMargin,
--CD.UpdateMarginpercent,CD.InCostFile,CD.OperatorName,cd.ProposedRouteId,CD.UpdateCost 
--FROM CostSessionData CD INNER JOIN CostSession CS 
--ON CD.SESSIONID=CS.SESSIONID WHERE CD.SESSIONID=@SessionId AND CS.STATUS=1 AND CD.Impact='Yes'

   
END
