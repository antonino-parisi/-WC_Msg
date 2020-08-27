-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <26 April 2012>
-- Description:	This stored procedure calculates the Service total 
-- and update the Account totals based on message type,subaccountid and date
-- =============================================
 CREATE PROCEDURE  [dbo].[usp_ComputeServiceTotal]
	-- Add the parameters for the stored procedure here
	--@cdate  VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @SubAccount_Cursor  NVARCHAR(MAX);
	Declare @SubAccounId NVARCHAR(50)
	DECLARE @MessageType NVARCHAR(50)	
	Declare @AccounId NVARCHAR(50)
	DECLARE @begin date
	DECLARE @end date
	DECLARE @datetime datetime
	DECLARE @Mcount as int
	SET @begin  =CONVERT(datetime,GETDATE()) ;
	SET @end = DATEADD(day, 1, @begin);
	 
	-- we First delete the element of the corresponding date ( should be empty)	
	Delete from AccountTotals where Date= @begin 
		 		 
	--DECLARE SubAccount_Cursor CURSOR FOR
	--SELECT SubAccountId
	--FROM Account WITH(NOLOCK)	
	--OPEN SubAccount_Cursor
	--FETCH NEXT FROM SubAccount_Cursor INTO @SubAccount_Cursor ;
	WHILE @@FETCH_STATUS = 0
		BEGIN		
			--SET @AccounId = ( Select AccountId FROM Account Where  @SubAccount_Cursor=SubAccountId); 
			DECLARE Traffic_Cursor CURSOR FOR
			SELECT SubAccountId,MessageType,count(*) as Mcount
				FROM TrafficRecord WITH(NOLOCK)
				WHERE 
				--TrafficRecord.SubAccountId =@SubAccount_Cursor 
				--AND 
				DatetimeStamp >=@begin AND datetimeStamp <@end  
				GROUP By  SubAccountId,MessageType			
			OPEN Traffic_Cursor			
			FETCH NEXT FROM Traffic_Cursor   INTO @SubAccounId, @MessageType,@Mcount									
			WHILE @@FETCH_STATUS = 0
			
			BEGIN
			select   @SubAccounId, @MessageType,@Mcount												
				if exists (select * from AccountTotals 
				where SubAccountId=@SubAccounId and [Date]=@begin and MessageType = @MessageType)
			begin
			UPDATE AccountTotals SET Total = Total+@Mcount WHERE SubAccountId = @SubAccounId
			AND [Date] = @begin AND MessageType = @MessageType
		end
		else
		begin
		BEGIN TRY
			INSERT INTO AccountTotals (SubAccountId, [Date], MessageType, Total)
				VALUES (@SubAccounId, @begin, @MessageType, @Mcount)
		END TRY
		BEGIN CATCH
		UPDATE AccountTotals SET Total = Total+@Mcount WHERE SubAccountId = @SubAccounId
			AND [Date] = @begin AND MessageType = @MessageType
		END CATCH
		end									
			FETCH NEXT FROM Traffic_Cursor   INTO @SubAccounId, @MessageType,@Mcount		
			END;
				
			CLOSE Traffic_Cursor
			DEALLOCATE Traffic_Cursor;												 
			
			--FETCH NEXT FROM SubAccount_Cursor INTO @SubAccount_Cursor ;
			
		END;
	--CLOSE SubAccount_Cursor
	--DEALLOCATE SubAccount_Cursor;
--select 1

END



























