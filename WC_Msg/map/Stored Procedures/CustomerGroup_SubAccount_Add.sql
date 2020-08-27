
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-13
-- Updated by:   Raymond Torino
-- Updated date: 2018-03-22
-- =============================================
-- EXEC map.[CustomerGroup_SubAccount_Add] @CustomerGroupId = 2, ...
CREATE PROCEDURE [map].[CustomerGroup_SubAccount_Add]
	@CustomerGroupId int,
	@SubAccountUid int
AS
BEGIN
	
	-- Hard delete of prev deleted record
	DELETE TOP (1) FROM rt.CustomerGroupSubAccount
	WHERE CustomerGroupId = @CustomerGroupId AND 
		SubAccountUid = @SubAccountUid
		AND Deleted = 1 -- constraint added by Anton on 2020-06-10. For update operation -> use map.CustomerGroup_SubAccount_Assign

	-- main operation
	INSERT INTO rt.CustomerGroupSubAccount (CustomerGroupId, SubAccountUid)
	VALUES (@CustomerGroupId, @SubAccountUid)

	-- routing V1
	IF NOT EXISTS (SELECT 1 FROM rt.SubAccount_Default WHERE SubAccountUid = @SubAccountUid)
		INSERT INTO rt.SubAccount_Default (SubAccountUid, RoutingPlanId_Default, PricingPlanId_Default)
			VALUES (@SubAccountUid, 3 /* cp_curated routing */, 3 /* cp_curated pricing */)
    
	-- setup of basic properties
	EXEC ms.SubAccount_SetupBasics_Internal @SubAccountUid = @SubAccountUid, @Product = 'SM'

END
