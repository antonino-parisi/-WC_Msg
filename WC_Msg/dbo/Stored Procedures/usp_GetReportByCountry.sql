-- =============================================
-- Author:		Raju Gupta
-- Create date: 20/10/2011
-- Description:	return the report based on country
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetReportByCountry]  
@StartDate DATE,
@EndDate DATE,
@RouteId NVARCHAR(100),  
@AccountId NVARCHAR(50),
@SubAccountId NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--IF @AccountId='All' AND @RouteId='All' 
IF @AccountId='All' AND @SubAccountId='All'  AND @RouteId='All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate  group by accountId,country
--where date between @StartDate  AND @EndDate group by accountId,country,OperatorName
END

--And AccountId not in('Netval1','KameleanGroup')
--IF @AccountId='All' AND @RouteId<>'All' 
IF @AccountId='All' AND @SubAccountId='All' AND @RouteId<>'All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND RouteId =@RouteId  group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId group by accountId,country,OperatorName
END
--And AccountId not in('Netval1','KameleanGroup')
--IF @AccountId<>'All' AND @RouteId='All'

IF @AccountId='All' AND @SubAccountId<>'All' AND @RouteId='All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND SubAccountId=@SubAccountId 
--AND AccountId =@AccountId 
group by accountId,country
--where date between @StartDate  AND @EndDate AND AccountId =@AccountId group by accountId,country,OperatorName
END
--And AccountId not in('Netval1','KameleanGroup')
--IF @AccountId<>'All' AND @RouteId<>'All' 
IF @AccountId<>'All' AND @SubAccountId='All' AND @RouteId='All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND AccountId =@AccountId group by accountId,country,OperatorName
END



IF @AccountId='All' AND @SubAccountId<>'All' AND @RouteId<>'All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND SubAccountId=@SubAccountId AND RouteId =@RouteId  group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND AccountId =@AccountId group by accountId,country,OperatorName
END
--And AccountId not in('Netval1','KameleanGroup')
IF @AccountId<>'All' AND @SubAccountId<>'All' AND @RouteId='All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND SubAccountId=@SubAccountId group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND AccountId =@AccountId group by accountId,country,OperatorName
END


IF @AccountId<>'All' AND @SubAccountId='All' AND @RouteId<>'All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND RouteId =@RouteId group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND AccountId =@AccountId group by accountId,country,OperatorName
END

IF @AccountId<>'All' AND @SubAccountId<>'All' AND @RouteId<>'All' 
BEGIN
Select AccountId,country,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND SubAccountId=@SubAccountId AND RouteId =@RouteId group by accountId,country
--where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND AccountId =@AccountId group by accountId,country,OperatorName
END


END

