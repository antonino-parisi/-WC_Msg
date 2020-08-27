-- =============================================
-- Author:		<Author,,Raju Gupta>
-- Create date: <Create Date,09-07-2014,>
-- Description:	stored procedure used to find message from Search page(Admin portal)
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchMessagebyOpid] 
	@AccountId VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@Source VARCHAR(50),
	@MessageType VARCHAR(50),
	@Umid VARCHAR(MAX),
	@Country VARCHAR(MAX),
	@DateBegin DATETIME,
	@DateEnd DATETIME,
	@OperatorId varchar(50),
	@MessageLimitCount int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--SELECT CONVERT(char(10), GetDate(),126)
	--declare
	--@DateBegin DATETIME,
	--	@DateEnd DATETIME
	--set @DateBegin=CONVERT(char(10), @DateBegin1,126)
	--set @DateEnd=CONVERT(char(10), @DateEnd1,126)
	
	CREATE TABLE #TEMPTABLE_report1
(    UMID varchar(50),
     SubAccountId nvarchar(50),
     RouteIdUsed nvarchar(50),
     MessageType varchar(50),
     Source varchar(50),
     Destination varchar(50),
     DateTimeStamp datetime,
     Status varchar(50),
     OperatorId varchar(50),
     CorrelationId nvarchar(50)
     
)
	
	
	
--	CREATE TABLE #TEMPTABLE_report2
--(
--     SubAccountId nvarchar(50),
--     RouteIdUsed nvarchar(50),
--     MessageType varchar(50),
--     Source varchar(50),
--     Destination varchar(50),
--     DateTimeStamp datetime,
--     Status varchar(50),
--     OperatorId varchar(50),
--     CorrelationId nvarchar(50)
     
--)
	
	
	if(@MessageLimitCount=10)
	begin
	
	---When All account selected
	
	
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29

		--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	
	
	
else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1 SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId  order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		
	--UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/		
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId
			-- UNION ALL

		/*
		NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
	
		insert into #TEMPTABLE_report1	SELECT TOP 10 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId
		*/			
	
	end	
		select top 10 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
		
	---------------------------20
	if(@MessageLimitCount=20)
	begin
	
	
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
	
	--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	
	else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
	--	UNION ALL
	insert into #TEMPTABLE_report1	SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			-- UNION ALL
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29

		insert into #TEMPTABLE_report1 SELECT TOP 20 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	
	end	
		select top 20 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
	
	---------------------50
	
	if(@MessageLimitCount=50)
	begin
	
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
	
	--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29

			--UNION ALL
		insert into #TEMPTABLE_report1	SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			-- UNION ALL
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		
		insert into #TEMPTABLE_report1	SELECT TOP 50 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	
	end	
		select top 50 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
		
		
		
    if(@MessageLimitCount=100)
	begin
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			--UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			-- UNION ALL
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		insert into #TEMPTABLE_report1 SELECT TOP 100 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	
	end	
		select top 100 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
		
		
		
		if(@MessageLimitCount=500)
	begin
	
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	
	
	else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc

	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			--UNION ALL
		insert into #TEMPTABLE_report1 SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			-- UNION ALL
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		insert into #TEMPTABLE_report1 SELECT TOP 500 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	
	end	
		select top 500 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
		
		
		
	if(@MessageLimitCount=1000)
	begin
	
	
	if (@AccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			--AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		--	UNION ALL
	insert into #TEMPTABLE_report1 SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId 
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			--AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else if (@SubAccountId='')
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		--	UNION ALL
		insert into #TEMPTABLE_report1	SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	end
	else
	begin
	insert into #TEMPTABLE_report1	SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd ) And OperatorId=@OperatorId order by DateTimeStamp desc
			-- UNION ALL
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
			
		insert into #TEMPTABLE_report1	SELECT TOP 1000 UMID,SubAccountId,RouteIdUsed,MessageType,Source,Destination,DateTimeStamp, Status,OperatorId,CorrelationId   
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  And OperatorId=@OperatorId order by DateTimeStamp desc
	*/			
	
	end	
		select top 1000 * from #TEMPTABLE_report1 order by datetimestamp desc
		end
		
	
	
	--union all select top 10 * from #TEMPTABLE_report2
	
	drop table #TEMPTABLE_report1
	--drop table #TEMPTABLE_report2
	
END
