-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_StatsMessagesMOMTRatio] 
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
	
		DECLARE @prefix AS  NVARCHAR(10);

	set @prefix = '%';
	if ( @Country<>'')
	BEGIN
	set @prefix = ( select dialing_codes.Code from dialing_codes WHERE ( dialing_codes.Country=@Country))+'%'
	END
	
	-- If there is not SubAccountId, we list all the countries
	IF (@SubAccountId='')
		BEGIN
		SELECT TrafficRecord.MessageType ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK)  
			WHERE	( @MessageType = '' OR TrafficRecord.MessageType = @MessageType) 
			AND		( @Source = '' OR TrafficRecord.Source = @Source) 
			AND		 TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId = @AccountId) 
			AND		( TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd ) 
			AND		( @Country = '' OR '+'+TrafficRecord.Destination LIKE @prefix)
			GROUP BY TrafficRecord.MessageType	
		END
	ELSE
		BEGIN
		-- Insert statements for procedure here
		if EXISTS (SELECT * FROM Account WHERE AccountId = @AccountID AND SubAccountId = @SubAccountId)
		BEGIN
		SELECT TrafficRecord.MessageType ,COUNT(*) AS TOTAL  FROM [dbo].[TrafficRecord] WITH(NOLOCK)     
			WHERE	( @MessageType = '' OR TrafficRecord.MessageType = @MessageType) 
			AND		( @Source = '' OR TrafficRecord.Source = @Source) 
			AND		TrafficRecord.SubAccountId = @SubAccountId 
			AND		( TrafficRecord.DateTimeStamp BETWEEN @DateBegin  AND @DateEnd )  
			AND		( @Country = '' OR '+'+TrafficRecord.Destination LIKE @prefix)
			GROUP BY TrafficRecord.MessageType	
		END
	END
END
