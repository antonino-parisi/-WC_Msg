
CREATE PROCEDURE [dbo].[usp_GetCPStat_Details]  
@StartDate DATE,
@EndDate DATE,
@Country NVARCHAR(50),  
@AccountId NVARCHAR(50),
@SubAccountId NVARCHAR(50),
@MessageType varchar(50)

AS
Begin
	-- =============================================
-- Author:		Raju Gupta
-- Create date: 26/12/2014
-- Description:	return details stat
-- =============================================
	
SET NOCOUNT ON;
CREATE TABLE #TEMPTABLE_livetraffic1
(
     Country nvarchar(max),
    OperatorName nvarchar(max),
   -- OperatorId varchar(max),
    --RouteIdUsed nvarchar(max),
    TotalMessages int,
    DELIVEREDTODEVICE int,
    DELIVEREDTOCARRIER int,
    REJECTEDBYCARRIER int,
    SENT  int,
    --RECEIVEDFORPROCESSING int,
   -- TRASHED int,
   -- NOROUTEAVAILABLE int,
    REJECTEDBYDEVICE int, 
    PARTOFAMESSAGE int,
    TotalPrice decimal(18,5),
    --TotalCost decimal(18,5)      
)

DECLARE @ArchiveMaxDate datetime = DATEADD(DAY, -9, GETUTCDATE())

SET @EndDate=DATEADD(DAY, 1, @EndDate)
IF @MessageType='All' AND @SubAccountId='All' AND @Country='All'   --1
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName, --,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate   --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Status, Operator.OperatorName, TrafficRecord.OperatorId,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName,--TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			  case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			  case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	 --,SUM(Cost) as TotalCost		   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate  --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,
					SUM(SENT) as SENT,
					sum(TotalPrice) as TotalPrice --sum(TotalCost) as TotalCost,
					--SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName			
					
					
	END				
	
	IF @MessageType='All'  AND @SubAccountId='All' AND @Country<>'All' --2
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country ,Operator.OperatorName, --,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
		--	case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
		--	case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
		-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	--,SUM(Cost) as TotalCost		   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and Operator.Country=@Country  --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName, --,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	--,SUM(Cost) as TotalCost		   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						DatetimeStamp between @StartDate   AND @EndDate  and Operator.Country=@Country --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,
					--SUM(TRASHED)as TRASHED,SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,
					sum(TotalPrice) as TotalPrice --,sum(TotalCost) as TotalCost,
					--SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName				
END
	
	
				--IF @AccountId<>'All' AND @Country='All'
				IF @MessageType='All'  AND @SubAccountId<>'All' AND @Country='All' --3
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName,--TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	--,SUM(Cost) as TotalCost		   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  --and RouteIdUsed  --NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName,--TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,			   
			   SUM(Price) as TotalPrice --SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate -- and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,
					--SUM(TRASHED)as TRASHED,SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,
					sum(TotalPrice) as TotalPrice --sum(TotalCost) as TotalCost
					--SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName	
	END				
	
	
	
				
--IF @AccountId<>'All' AND @Country<>'All' 
IF @MessageType<>'All'  AND @SubAccountId='All' AND @Country='All' --4
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName, --,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			-- case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						 and MessageType=@MessageType
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName, --,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			-- case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType=@MessageType
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					--SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice
					--sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName
	END				
		
		
		
		IF @MessageType='All'  AND @SubAccountId<>'All' AND @Country<>'All' --5
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName,--TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and Operator.Country=@Country --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName, --TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate and Operator.Country=@Country --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					--SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice
					--sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName	
	END				
		
				
		IF @MessageType<>'All'  AND @SubAccountId<>'All' AND @Country='All' --6
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName, --,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice--,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate  --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType=@MessageType
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName, --TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType=@MessageType
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					--SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice
				--	sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
				--	SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName
	END				
		
		
		
		
			IF @MessageType<>'All'  AND @SubAccountId='All' AND @Country<>'All' --7
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName, --,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate and Operator.Country=@Country --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType=@MessageType
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName,--TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and Operator.Country=@Country  --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType=@MessageType
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					--SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice
					--sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
					--(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName
	END				
		
		
		
		
			
			IF @MessageType<>'All'  AND @SubAccountId<>'All' AND @Country<>'All'  --8
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , Operator.OperatorName,--TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			-- case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate and Operator.Country=@Country --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType=@MessageType
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , Operator.OperatorName,--TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			--case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			--case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 --case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice --,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed=@Country  --and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and @StartDate < @ArchiveMaxDate
						and MessageType=@MessageType
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,OperatorName,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					--SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					--SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice
					--sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/sum(cast(TotalMessages as decimal))*100 as DeliveryRate,
				--	(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					--SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/sum(cast(TotalMessages as decimal))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country,OperatorName	
	END				
		
		
	
	
	drop table #TEMPTABLE_livetraffic1
END
				
					
					
				