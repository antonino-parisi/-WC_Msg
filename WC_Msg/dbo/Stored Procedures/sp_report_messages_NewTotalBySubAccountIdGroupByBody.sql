CREATE PROCEDURE [dbo].[sp_report_messages_NewTotalBySubAccountIdGroupByBody]
			@SubAccountId nvarchar(50),
			@StartDate DateTime,
			@EndDate DateTime
			
AS
select Body, MessageType, count(*) as Total
from TrafficRecord where DateTimeStamp between @StartDate and @EndDate
and SubAccountId = @SubAccountId and (MessageType = 'MT' or MessageType = 'MO')
group by Body, MessageType
order by Total desc
