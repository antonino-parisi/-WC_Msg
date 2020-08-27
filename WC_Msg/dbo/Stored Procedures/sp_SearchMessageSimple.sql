-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	stored procedure used to find message ( used by customer portal)
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchMessageSimple] 
	@AccountId VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@Source VARCHAR(50),
	@MessageType VARCHAR(50),
	@Umid VARCHAR(MAX),
	@Country VARCHAR(MAX),
	@DateBegin DATETIME,
	@DateEnd DATETIME		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	if (@AccountId='')
	begin
		SELECT TOP 1000 *  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
		--	AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )

	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		UNION
		SELECT TOP 1000 *  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
		--	AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )
	*/			
	end
	
	
	else if (@SubAccountId='')
	begin
		SELECT TOP 1000 *  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )
		/*
		NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29

		UNION
		SELECT TOP 1000 *  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId ) 
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )
		*/		
	end
	else
	begin
		SELECT TOP 1000 *  
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND  TrafficRecord.SubAccountId=@SubAccountId
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )  
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		UNION
		SELECT TOP 1000 *  
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
			AND  TrafficRecordArchive.SubAccountId=@SubAccountId
			AND ( TrafficRecordArchive.DateTimeStamp >@DateBegin  AND TrafficRecordArchive.DateTimeStamp <@DateEnd )  
	*/			
	
	end	
		
		
		
	
END
