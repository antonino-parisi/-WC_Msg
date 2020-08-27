-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_StatsMessagesByCountry] 
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
	
	
	
	-- If there is not SubAccountId, we list all the countries
	If (@Source='')
	BEGIN
		IF (@SubAccountId='')
			BEGIN
			SELECT dialing_codes.Country , dialing_codes.CodeCountry, Sum(TotalMessage) AS TOTAL  FROM dialing_codes   JOIN MessageStats   ON ( MessageStats.country= dialing_codes.Country )
			WHERE ( @MessageType='' OR MessageStats.MessageType=@MessageType) 
			AND ( @Source='' ) 
			AND  MessageStats.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
			AND ( MessageStats.date >=@DateBegin  AND MessageStats.date <=@DateEnd )  
			AND(@Country='' OR dialing_codes.Country=@Country)
			GROUP BY dialing_codes.Country,dialing_codes.CodeCountry
			END
		ELSE
			BEGIN
			-- Insert statements for procedure here
			if EXISTS (SELECT * FROM Account WHERE AccountId=@AccountID AND SubAccountId=@SubAccountId)
			BEGIN
					SELECT dialing_codes.Country , dialing_codes.CodeCountry, Sum(TotalMessage) AS TOTAL  FROM dialing_codes   JOIN MessageStats   ON ( MessageStats.country= dialing_codes.Country )
			WHERE ( @MessageType='' OR MessageStats.MessageType=@MessageType) 
			AND ( @Source='' )  
					AND  MessageStats.SubAccountId=@SubAccountId 
					AND ( MessageStats.date >=@DateBegin  AND MessageStats.date <=@DateEnd )  
			AND(@Country='' OR dialing_codes.Country=@Country)
			GROUP BY dialing_codes.Country,dialing_codes.CodeCountry
			END
			END
	END
	ELSE
	BEGIN
		set @DateEnd = DATEADD(day,1,@DateEnd ) 
		IF (@SubAccountId='')
		BEGIN
		SELECT dialing_codes.Country , dialing_codes.CodeCountry, COUNT(*) AS TOTAL  FROM dialing_codes   JOIN TrafficRecord   ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' )
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
		AND ( @Source='' OR TrafficRecord.Source=@Source) 
		AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
		AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )  
		AND(@Country='' OR dialing_codes.Country=@Country)
		GROUP BY dialing_codes.Country,dialing_codes.CodeCountry
		END
	ELSE
		BEGIN
		-- Insert statements for procedure here
		if EXISTS (SELECT * FROM Account WHERE AccountId=@AccountID AND SubAccountId=@SubAccountId)
		BEGIN
		SELECT dialing_codes.Country , dialing_codes.CodeCountry, COUNT(*) AS TOTAL  FROM dialing_codes   JOIN TrafficRecord   ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' )
				WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND ( @Source='' OR TrafficRecord.Source=@Source) 
			AND  TrafficRecord.SubAccountId=@SubAccountId 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )  
			AND(@Country='' OR dialing_codes.Country=@Country)
			GROUP BY dialing_codes.Country,dialing_codes.CodeCountry
	
		END
	END
	END
END
