CREATE PROCEDURE [dbo].[sp_web_SearchTrafficRecordBySubAccountIdDestination]
		@SubAccountId NVARCHAR(50),	
		@Destination VARCHAR(50)

AS
SET NOCOUNT ON;
select * from [dbo].[TrafficRecord] WITH(NOLOCK) where SubAccountId = @SubAccountId and
Destination = @Destination and MessageType != 'MOOUT'
order by DateTimeStamp desc
