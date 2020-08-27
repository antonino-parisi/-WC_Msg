

CREATE VIEW [rpt].[bi_rt.vwRoutingPlanCoverageAllConn]
AS
SELECT 
RoutingPlanCoverageId,
RoutingPlanId,
RoutingPlanName, 
c.CountryName,
OperatorId,
OperatorName,
TierLevelCurrent,
TierLevel,
RoutingTierId,
CostCalculated,
CostCurrency,
UpdatedBy,
UpdatedAt,
ConnId,
ConnStatus,
ConnWeight
from rt.vwRoutingPlanCoverageAllConn rt left join mno.Country c on c.CountryISO2alpha = rt.Country
where RTC_Deleted = 0 and Deleted = 0 and RG_Deleted = 0 and rt_deleted = 0 and not RoutingPlanName like '%deleted%'
