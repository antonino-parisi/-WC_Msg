
CREATE PROCEDURE [ms].[RateLimits_GetAll]
AS
BEGIN
    SELECT ISNULL(sa.SubAccountId, '*') AS SubAccountId, Method, Endpoint, Period, Limit
    FROM ms.RateLimits rl
        LEFT JOIN ms.SubAccount sa ON rl.SubAccountUid = sa.SubAccountUid​ and sa.Active = 1
END
