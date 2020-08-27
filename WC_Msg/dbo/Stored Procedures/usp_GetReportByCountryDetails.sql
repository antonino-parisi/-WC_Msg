
CREATE PROCEDURE [dbo].[usp_GetReportByCountryDetails]  
@StartDate DATE,
@EndDate DATE,
@RouteId NVARCHAR(100),  
@AccountId NVARCHAR(50),
@SubAccountId NVARCHAR(50)
AS
Begin
	-- =============================================
-- Author:		Raju Gupta
-- Create date: 10/06/2013
-- Description:	return detail report based on carrier 
-- =============================================
	
	
	SET NOCOUNT ON;
	
CREATE TABLE #TEMPTABLE_livetraffic1
(
     Country nvarchar(max),
    --OperatorName nvarchar(max),
   -- OperatorId varchar(max),
    --RouteIdUsed nvarchar(max),
    TotalMessages int,
    DELIVEREDTODEVICE int,
    DELIVEREDTOCARRIER int,
    REJECTEDBYCARRIER int,
    SENT  int,
    RECEIVEDFORPROCESSING int,
    TRASHED int,
    NOROUTEAVAILABLE int,
    REJECTEDBYDEVICE int, 
    PARTOFAMESSAGE int,
    TotalPrice decimal(18,5),
    TotalCost decimal(18,5)      
)

SET @EndDate=DATEADD(DAY, 1, @EndDate)
IF @AccountId='All' AND @SubAccountId='All' AND @RouteId='All' 
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE --TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId='Appvoice')AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Status, Operator.OperatorName, TrafficRecord.OperatorId,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			  case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			  case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	,SUM(Cost) as TotalCost		   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  --TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId='Appvoice') AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,
					SUM(TRASHED)as TRASHED,SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,sum(TotalCost) as TotalCost,
					SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country			
					
					
	END				
	
	IF @AccountId='All'  AND @SubAccountId='All' AND @RouteId<>'All' 
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	,SUM(Cost) as TotalCost		   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE --TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId='Appvoice')AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed=@RouteId  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	,SUM(Cost) as TotalCost		   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  --TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId='Appvoice') AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed=@RouteId and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,
					SUM(TRASHED)as TRASHED,SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,
					sum(TotalPrice) as TotalPrice,sum(TotalCost) as TotalCost,
					SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country				
END
	
	
				--IF @AccountId<>'All' AND @RouteId='All'
				IF @AccountId='All'  AND @SubAccountId<>'All' AND @RouteId='All' 
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice	,SUM(Cost) as TotalCost		   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			   case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			   case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,			   
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,
					SUM(TRASHED)as TRASHED,SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,
					SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,
					sum(TotalPrice) as TotalPrice,sum(TotalCost) as TotalCost,
					SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
	
	
	
				
--IF @AccountId<>'All' AND @RouteId<>'All' 
IF @AccountId<>'All'  AND @SubAccountId='All' AND @RouteId='All'
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,
					sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
		
		
		
		IF @AccountId='All'  AND @SubAccountId<>'All' AND @RouteId<>'All'
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId)AND
						--TrafficRecord.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed=@RouteId and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where SubAccountId=@SubAccountId) AND
						--TrafficRecordArchive.SubAccountId  not in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId in('Netval1','KameleanGroup'))AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed=@RouteId and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,
					sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
		
				
		IF @AccountId<>'All'  AND @SubAccountId<>'All' AND @RouteId='All'
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,
					sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
		
		
		
		
			IF @AccountId<>'All'  AND @SubAccountId='All' AND @RouteId<>'All'
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate and RouteIdUsed=@RouteId and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed=@RouteId  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,
					sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
		
		
		
		
			
			IF @AccountId<>'All'  AND @SubAccountId<>'All' AND @RouteId<>'All'
BEGIN
insert into #TEMPTABLE_livetraffic1
			SELECT Operator.Country , --Operator.OperatorName,TrafficRecord.OperatorId,RouteIdUsed, 
			COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			   SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   		   
						FROM TrafficRecord WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecord.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE TrafficRecord.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId)AND
						 DatetimeStamp between @StartDate   AND @EndDate and RouteIdUsed=@RouteId and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')
						--and Status<>'RECEIVED FOR PROCESSING' and Status<>'TRASHED' and status<>'NO ROUTE AVAILABLE'
						and MessageType<>'MOOut'
						GROUP By  Operator.Country,Operator.OperatorName, TrafficRecord.OperatorId,Status,RouteIdUsed 					
					UNION ALL																																								
		SELECT Operator.Country , --Operator.OperatorName,TrafficRecordArchive.OperatorId,RouteIdUsed, 
		COUNT(*) as TotalMessages,
			case when Status='DELIVERED TO DEVICE' THEN count(*) ELSE 0 end as DELIVEREDTODEVICE ,
			case when Status='DELIVERED TO CARRIER' THEN count(*) ELSE 0 end as DELIVEREDTOCARRIER,
			case when Status='REJECTED BY CARRIER' THEN count(*)ELSE 0 end as REJECTEDBYCARRIER,
			case when Status='SENT' THEN count(*) ELSE 0 end as SENT,
			case when Status='RECEIVED FOR PROCESSING' THEN count(*) ELSE 0 end as RECEIVEDFORPROCESSING,
			case when Status='TRASHED' THEN count(*) ELSE 0 end  as TRASHED,
			 case when Status='NO ROUTE AVAILABLE' THEN count(*)ELSE 0 end  as NOROUTEAVAILABLE,
			 case when Status='REJECTED BY DEVICE' THEN count(*) ELSE 0 end as REJECTEDBYDEVICE,
			 case when Status='PART OF A MESSAGE' THEN count(*) ELSE 0 end as PARTOFAMESSAGE,
			 SUM(Price) as TotalPrice,SUM(Cost) as TotalCost			   			   
						FROM TrafficRecordArchive WITH(NOLOCK)LEFT OUTER JOIN Operator on Operator.OperatorId=TrafficRecordArchive.OperatorId
						--WHERE @SubAccount_Cursor = TrafficRecord.SubAccountId 
						WHERE  TrafficRecordArchive.SubAccountId in(SELECT SubAccountId FROM Account WITH(NOLOCK) where AccountId=@AccountId and SubAccountId=@SubAccountId) AND
						 DatetimeStamp between @StartDate AND @EndDate and RouteIdUsed=@RouteId  and RouteIdUsed NOT IN('profyleNotification','profyleNotification_dev')						
						and MessageType<>'MOOut'
						GROUP By  Operator.Country, Operator.OperatorName, TrafficRecordArchive.OperatorId,Status,RouteIdUsed									
					
					SELECT  ISNULL(Country,'unknown') as Country,SUM(TotalMessages)as TotalMessages ,
					SUM(DELIVEREDTODEVICE)as DELIVEREDTODEVICE,
					SUM(DELIVEREDTOCARRIER)as DELIVEREDTOCARRIER,
					SUM(REJECTEDBYCARRIER)as REJECTEDBYCARRIER,SUM(SENT)as SENT,
					SUM(RECEIVEDFORPROCESSING)as RECEIVEDFORPROCESSING,SUM(TRASHED)as TRASHED,
					SUM(NOROUTEAVAILABLE)as NOROUTEAVAILABLE,SUM(REJECTEDBYDEVICE) as REJECTEDBYDEVICE,
					SUM(PARTOFAMESSAGE) as PARTOFAMESSAGE,sum(TotalPrice) as TotalPrice,
					sum(TotalCost) as TotalCost,SUM(cast(DELIVEREDTODEVICE as decimal))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as DeliveryRate,
					(SUM(cast(DELIVEREDTODEVICE as decimal))+SUM(cast(DELIVEREDTOCARRIER as decimal))+SUM(cast(SENT as decimal))	+				
					SUM(cast(RECEIVEDFORPROCESSING as decimal))+SUM(cast(REJECTEDBYDEVICE as decimal)))/(sum(cast(TotalMessages as decimal))-sum(cast(PARTOFAMESSAGE as decimal)))*100 as WavecellDeliveryRate
					FROM #TEMPTABLE_livetraffic1 group by Country	
	END				
		
		
		
		
		
		
		
	
	drop table #TEMPTABLE_livetraffic1
END
				
					
					
				