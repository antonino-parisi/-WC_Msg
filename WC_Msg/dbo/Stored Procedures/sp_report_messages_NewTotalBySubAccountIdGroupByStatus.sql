CREATE PROCEDURE [dbo].[sp_report_messages_NewTotalBySubAccountIdGroupByStatus]
			@SubAccountId nvarchar(50),
			@StartDate DateTime,
			@EndDate DateTime
			
AS
SET NOCOUNT ON;
select Status, MessageType, count(*) as Total
from [dbo].[TrafficRecord] WITH(NOLOCK) where DateTimeStamp between @StartDate and @EndDate
and SubAccountId = @SubAccountId
group by MessageType, Status
order by MessageType, Status, Total asc
