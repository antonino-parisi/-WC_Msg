
CREATE PROCEDURE [dbo].[sp_StatsMessagesByDay] 
	-- Add the parameters for the stored procedure here
		@AccountId VARCHAR(50),
		@SubAccountId VARCHAR(50),
		@Source VARCHAR(50),
		@MessageType VARCHAR(50),
		@Country VARCHAR(50),
		@DateBegin DATETIME,
		@DateEnd DATETIME
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @DateEnd = DATEADD(day,1,@DateEnd ) 
	DECLARE @prefix AS  NVARCHAR(10);
	set @prefix = '%';
	
	IF (@Country = '')
	BEGIN
		IF (@SubAccountId = '')
		BEGIN
			IF (@Source = '')
			BEGIN
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
			ELSE
			BEGIN -- (source <> '')
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						AND (TrafficRecordArchive.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source) 
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						AND (TrafficRecordArchive.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
		END
		ELSE --(subAcc <> '')
		BEGIN
			IF (@Source = '')
			BEGIN
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
			ELSE
			BEGIN -- (source <> '')
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						AND (TrafficRecordArchive.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source) 
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						AND (TrafficRecordArchive.Source = @Source)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
		END
	END
	ELSE --(country <> '')
	BEGIN
		set @prefix = ( select dialing_codes.Code from dialing_codes WHERE ( dialing_codes.Country=@Country))+ '%'
		
		IF (@SubAccountId = '')
		BEGIN
			IF (@Source = '')
			BEGIN
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Destination LIKE @prefix) 
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
			ELSE
			BEGIN -- (source <> '')
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						AND (TrafficRecordArchive.Source = @Source)
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						AND (TrafficRecordArchive.Source = @Source)
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
		END
		ELSE --(subAcc <> '')
		BEGIN
			IF (@Source = '')
			BEGIN
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Destination LIKE @prefix) 
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
			ELSE
			BEGIN -- (source <> '')
				IF(@MessageType = '')
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)  
						AND (TrafficRecordArchive.Source = @Source)
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
				ELSE
				BEGIN
					SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
						WHERE  TrafficRecord.SubAccountId = @SubAccountId
						AND (TrafficRecord.MessageType=@MessageType) 
						AND (TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd)
						AND (TrafficRecord.Source = @Source)
						AND (TrafficRecord.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
					UNION
					SELECT convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101) AS EVENT_DATE ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecordArchive] WITH(NOLOCK)
						WHERE  TrafficRecordArchive.SubAccountId = @SubAccountId
						AND (TrafficRecordArchive.MessageType=@MessageType)
						AND ( TrafficRecordArchive.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
						AND (TrafficRecordArchive.Source = @Source)
						AND (TrafficRecordArchive.Destination LIKE @prefix)
						GROUP BY convert(varchar(10),TrafficRecordArchive.DateTimeStamp ,101)
					ORDER BY EVENT_DATE
				END
			END
		END
	END
END
			
	
	
	

