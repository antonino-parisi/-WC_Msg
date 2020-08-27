-- =============================================
-- Author:		Raju Gupta
-- Create date: 20/10/2011
-- Description:	return the report based on carrier 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetReportByCarrier]  
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
---All Accountid
IF @AccountId='All' AND @SubAccountId='All'  AND @RouteId='All' 
BEGIN
Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate  group by accountId,country,OperatorName,RouteId
END
--And AccountId not in('Netval1','KameleanGroup')
---All Accountid
IF @AccountId='All' AND @SubAccountId='All' AND @RouteId<>'All' 
BEGIN
Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND RouteId =@RouteId  group by accountId,country,OperatorName,RouteId
END
--And AccountId not in('Netval1','KameleanGroup')
---All Accountid
--IF @AccountId<>'All' AND @RouteId='All'
IF @AccountId='All' AND @SubAccountId<>'All' AND @RouteId='All' 
BEGIN
Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND SubAccountId=@SubAccountId  --AND AccountId =@AccountId 
group by accountId,country,OperatorName,RouteId
END
--And AccountId not in('Netval1','KameleanGroup')
--IF @AccountId<>'All' AND @RouteId<>'All' 

IF @AccountId<>'All' AND @SubAccountId='All' AND @RouteId='All' 
BEGIN

Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId group by accountId,country,OperatorName,RouteId

END

---All Accountid
IF @AccountId='All' AND @SubAccountId<>'All' AND @RouteId<>'All' 
BEGIN

Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND RouteId =@RouteId  AND SubAccountId=@SubAccountId        --AND AccountId =@AccountId 
group by accountId,country,OperatorName,RouteId

END
--And AccountId not in('Netval1','KameleanGroup')

IF @AccountId<>'All' AND @SubAccountId<>'All' AND @RouteId='All' 
BEGIN

Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND SubAccountId=@SubAccountId
group by accountId,country,OperatorName,RouteId

END




IF @AccountId<>'All' AND @SubAccountId='All' AND @RouteId<>'All' 
BEGIN

Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND RouteId =@RouteId
--AND SubAccountId=@SubAccountId
group by accountId,country,OperatorName,RouteId

END

IF @AccountId<>'All' AND @SubAccountId<>'All' AND @RouteId<>'All' 
BEGIN

Select AccountId,OperatorName,Sum(TotalMessage) TotalMessage,round(SUM(Price),2) TotalPrice,round(SUM(Cost),2) TotalCost,(round(SUM(Price),2)-round(SUM(Cost),2)) GrossMargin,country,RouteId from MessageStats 
where date between @StartDate  AND @EndDate AND AccountId =@AccountId AND SubAccountId=@SubAccountId AND RouteId =@RouteId
group by accountId,country,OperatorName,RouteId

END


END

