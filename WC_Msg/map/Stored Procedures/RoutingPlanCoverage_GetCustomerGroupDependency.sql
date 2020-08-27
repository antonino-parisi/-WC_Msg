-- =============================================
-- Author: Rebecca Loh
-- Create date: 22 Jul 2019
-- Description: Get records from rt.CustomerGroupCoverage which are using routing plan
-- Usage : EXEC map.RoutingPlanCoverage_GetCustomerGroupDependency @RoutingPlanId=3, @Country = 'ID'
-- =============================================
CREATE PROCEDURE [map].[RoutingPlanCoverage_GetCustomerGroupDependency]
    @RoutingPlanId int,
    @Country char(2) = NULL,
    @OperatorId int = NULL
AS
BEGIN
	DECLARE @Tab TABLE
		(CoverageId int,
		CustomerGroupId int,
		CustomerGroupName nvarchar(100),
		SubAccountUid int,
		SubAccountId varchar(50),
		Country char(2),
		OperatorId int
		) ; 

	INSERT INTO @Tab
	SELECT	c.CoverageId,
			c.CustomerGroupId,
			n.CustomerGroupName,
			c.SubAccountUid,
			IIF(c.SubAccountUid IS NULL, 'DEFAULT', a.SubAccountId) SubAccountId,
			c.Country,
			c.OperatorId
	FROM rt.CustomerGroupCoverage c WITH (NOLOCK)
		INNER JOIN rt.CustomerGroup n WITH (NOLOCK)
			ON c.CustomerGroupId = n.CustomerGroupId AND n.Deleted = 0
		LEFT JOIN dbo.Account a WITH (NOLOCK)
			ON c.SubAccountUid = a.SubAccountUid
	WHERE c.Deleted = 0
		AND c.RoutingPlanId = @RoutingPlanId
		AND (@Country IS NULL OR c.Country = @Country)
		AND (@OperatorId IS NULL OR c.OperatorId = @OperatorId) ;

	DELETE FROM T
	FROM @Tab T
	WHERE SubAccountUid IS NOT NULL
		AND EXISTS (SELECT 1 FROM @Tab
						WHERE CustomerGroupId = T.CustomerGroupId
							AND SubAccountUid IS NULL) ;
	
	SELECT t.*, o.OperatorName, c.CountryName
	FROM @Tab t
		LEFT JOIN mno.Operator o WITH (NOLOCK)
			ON t.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c WITH (NOLOCK)
			ON t.Country = c.CountryISO2Alpha ;
END
