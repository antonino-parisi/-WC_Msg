CREATE PROCEDURE [dbo].[sp_report_messages_NewTotalBySubAccountIdGroupByTariff]
			@SubAccountId nvarchar(50),
			@StartDate DateTime,
			@EndDate DateTime
			
AS
SET NOCOUNT ON;
select Tariff, count(*) as Total
from [dbo].[TrafficRecord] where DateTimeStamp between @StartDate and @EndDate
and SubAccountId = @SubAccountId and MessageType = 'MT'
group by Tariff
order by Tariff asc
