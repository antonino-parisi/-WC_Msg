-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_StatsMessages] 
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
	if ( @Country<>'')
	BEGIN
	set @prefix = ( select dialing_codes.Code from dialing_codes WHERE ( dialing_codes.Country=@Country))+ '%'
	END
	-- If there is not SubAccountId, we list all the countries
	IF (@Source='')
	
	BEGIN
		IF (@SubAccountId='')
		BEGIN
		SELECT convert(varchar(10),date,101) ,sum(TotalMessage) AS TOTAL  FROM [dbo].MessageStats WITH(NOLOCK)
			WHERE  (@MessageType='' OR MessageStats.MessageType = @MessageType)
			AND   MessageStats.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
			AND (MessageStats.date  >= @DateBegin  AND MessageStats.date  <@DateEnd )
			AND (@Country='' OR MessageStats.country=@Country)
			group by date
			order by date
		END
		ELSE
		BEGIN
		SELECT convert(varchar(10),date,101),sum(TotalMessage) AS TOTAL  FROM [dbo].MessageStats WITH(NOLOCK)
			WHERE  (@MessageType='' OR MessageStats.MessageType = @MessageType)
			AND   (MessageStats.SubAccountId = @SubAccountId) 
			AND (MessageStats.date  >= @DateBegin  AND MessageStats.date  <@DateEnd )
			AND (@Country='' OR MessageStats.country=@Country)
			group by date
			order by date
		END
	END
	ELSE
	BEGIN
			IF (@SubAccountId='')
		
		BEGIN
			SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK)
				WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
				AND ( @Source='' OR TrafficRecord.Source=@Source) 
				AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
				AND ( TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
				AND(@Country='' OR '+'+TrafficRecord.Destination LIKE @prefix)
				GROUP BY 	convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
				order by convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
	END
	ELSE
	
		BEGIN
			if EXISTS (SELECT * FROM Account WHERE AccountId=@AccountID AND SubAccountId=@SubAccountId)
		BEGIN
			SELECT convert(varchar(10),TrafficRecord.DateTimeStamp ,101) ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK)
				WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
				AND ( @Source='' OR TrafficRecord.Source=@Source) 
				AND  TrafficRecord.SubAccountId=@SubAccountId 
					AND ( TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )   
				AND(@Country='' OR '+'+TrafficRecord.Destination LIKE @prefix)
				GROUP BY 	convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
				order by convert(varchar(10),TrafficRecord.DateTimeStamp ,101)
		END
	END
  END
  
END
