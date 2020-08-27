-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,15-05-2015,>
-- Description:	<Calculate Traffic Delivery for Intelligent Routing>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalcTrafficDelivery]
	-- Add the parameters for the stored procedure here		
		--@SessionId NVARCHAR(250)				
AS
BEGIN
	
	
	DECLARE  @_accId NVARCHAR(50),@_subAccId NVARCHAR(50),@_opid NVARCHAR(200),@_rouId NVARCHAR(50) 
	 ---proposed routeid
	--DECLARE @_proprouteId NVARCHAR(50)	 
			
	DECLARE @OLDPRICE float,@NEWPRICE float
	DECLARE @EXTCOST float
	
	
  DECLARE @TOTALVALUME AS BIGINT
  DECLARE @DELIVEREDTODEVICE AS BIGINT
  DECLARE @PARTOFMESSAGE AS BIGINT
  DECLARE @DELIVERYRATE AS DECIMAL(18,4)
  DECLARE @MESSAGETHRLD AS INT
  SET @MESSAGETHRLD=100
  

 
  declare @Startime datetime,@Endtime datetime
  set @Endtime=GETDATE()
  set @Startime=DATEADD(HOUR, -1, @Endtime)
  
	SET NOCOUNT ON;

			
	DECLARE Subaccountid_Cursor CURSOR FOR
	select subaccountid from account  --where StandardRouteId in('intelligentrouting1')
	OPEN Subaccountid_Cursor
	FETCH NEXT FROM Subaccountid_Cursor INTO @_subAccId
	WHILE @@FETCH_STATUS = 0
	BEGIN			
	

     DECLARE TotalVolume_Cursor CURSOR FOR
     
     SELECT COUNT(*) FROM TrafficRecord WHERE DateTimeStamp between @Startime  and @Endtime and SubAccountId=@_subAccId group by RouteIdUsed,OperatorId
     OPEN TotalVolume_Cursor
     FETCH NEXT FROM TotalVolume_Cursor INTO @TOTALVALUME
     
     IF(@TOTALVALUME>=@MESSAGETHRLD)
     BEGIN
    Select @DELIVEREDTODEVICE=case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end,
   -- COUNT(*) as TotalMessages,
		 --   case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			--case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			--case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			--case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			--case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			@PARTOFMESSAGE=case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end 
     FROM TrafficRecord WITH(NOLOCK)WHERE DateTimeStamp between @Startime  and @Endtime and SubAccountId=@_subAccId  group by OperatorId,RouteIdUsed,Status
     
    
     SET @DELIVERYRATE=(@DELIVEREDTODEVICE/(@TOTALVALUME-@PARTOFMESSAGE))
     
     SELECT @_subAccId,@DELIVERYRATE,@TOTALVALUME,@DELIVEREDTODEVICE,@PARTOFMESSAGE,@Startime,@Endtime
     SET @TOTALVALUME=0
     SET @DELIVERYRATE=0
       FETCH NEXT FROM TotalVolume_Cursor INTO @TOTALVALUME
	END
	
     
    
    CLOSE TotalVolume_Cursor
	DEALLOCATE TotalVolume_Cursor

	 FETCH NEXT FROM Subaccountid_Cursor INTO @_subAccId
	END
	CLOSE Subaccountid_Cursor
	DEALLOCATE Subaccountid_Cursor
	

	END
	
	
	
	
	
	
	
	