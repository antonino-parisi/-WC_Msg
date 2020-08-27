-- =============================================
-- Author:		Raju Gupta
-- Create date: 15/07/2014
-- Description:	return the Websender history for Customer portal  
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetWebsenderHistory]  
@StartDate DATE,
@EndDate DATE,
@AccountId NVARCHAR(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @subaccountid as nvarchar(50)

select @subaccountid=SubAccountId  from Account  where AccountId=@AccountId and Description='Standard'

IF @StartDate='01/01/2010' AND @EndDate='01/01/2010'  
BEGIN
set @StartDate=DATEADD(day,-7, GETDATE())
set @EndDate=DATEADD(day,1, GETDATE())

Select top 10 Source,Destination,convert(varchar, DateTimeStamp, 103) Date,
Status,cast(DateTimeStamp as time)Time ,substring(Body,1,25) Body from TrafficRecord  where DateTimeStamp between @StartDate and @EndDate and SubAccountId=@subaccountid order by DateTimeStamp desc

END


IF @StartDate<>'01/01/2010' AND @EndDate<>'01/01/2010'  
BEGIN
set @EndDate=DATEADD(day,1, @EndDate)
Select Source,Destination,convert(varchar, DateTimeStamp, 103) Date,
Status,cast(DateTimeStamp as time)Time ,substring(Body,1,25) Body from TrafficRecord  where DateTimeStamp between @StartDate and @EndDate and SubAccountId=@subaccountid order by DateTimeStamp desc



END






END

