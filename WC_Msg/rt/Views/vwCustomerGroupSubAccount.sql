CREATE VIEW rt.vwCustomerGroupSubAccount 
AS
	SELECT cgs.*, cg.CustomerGroupName, sa.SubAccountId, sa.AccountId
	FROM rt.CustomerGroupSubAccount cgs
		LEFT JOIN rt.CustomerGroup cg ON cgs.CustomerGroupId = cg.CustomerGroupId 
		LEFT JOIN dbo.Account sa ON sa.SubAccountUid = cgs.SubAccountUid
