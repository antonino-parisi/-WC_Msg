---
-- =============================================
-- History:
-- 2020-03-12	Anton Shchekalov	Created
-- =============================================
-- EXEC cp.VirtualNumberRental_Get @AccountUid = 'asd', @UserUid = 'asd'
CREATE PROCEDURE [cp].[VirtualNumberRental_Get]
	@AccountUid uniqueidentifier,	-- mandatory
	@UserUid uniqueidentifier,		-- mandatory
	@SubAccountUid int = NULL,		-- optional filter
	@Country char(2) = NULL,		-- optional filter
	@VNType char(1) = NULL,			-- optional filter
	@VnRentalId int = NULL			-- optional filter
AS
BEGIN

	-- Get accessible subaccounts
	--DECLARE @SubAccounts AS TABLE (SubAccountUid int)
	--INSERT INTO @SubAccounts (SubAccountUid)
	--SELECT SubAccountUid
	--FROM cp.fnSubAccount_GetByUser (@AccountUid, @UserUid, @SubAccountUid, 1, DEFAULT, DEFAULT, DEFAULT) 
	
	SELECT
		r.VnRentalId,		
		vn.VNId,
		vn.VN,
		vn.VNType,
		vnt.VNTypeName,
		vn.Country,
		c.CountryName,
		r.SubaccountUid,
		r.RentalStart,
		r.RentalEnd,
		r.Currency,
		r.MonthlyFee
	FROM 
		ms.VirtualNumber vn
		INNER JOIN ms.VirtualNumberRental r ON r.VNId = vn.VNId
		-- Get accessible subaccounts
		INNER JOIN cp.fnSubAccount_GetByUser (@AccountUid, @UserUid, @SubAccountUid, 1, DEFAULT, DEFAULT, DEFAULT) sa 
			ON sa.SubAccountUid = r.SubAccountUid
		INNER JOIN mno.Country c ON vn.Country = c.CountryISO2alpha
		INNER JOIN ms.DimVirtualNumberType vnt ON vn.VNType = vnt.VNType
	WHERE 
		r.RentalStart <= SYSUTCDATETIME()
		AND r.RentalEnd >= SYSUTCDATETIME()
		-- optional filters
		AND (vn.Country = ISNULL(@Country, vn.Country))	
		AND (vn.VNType = ISNULL(@VNType, vn.VNType))
		AND (r.VnRentalId = ISNULL(@VnRentalId, r.VnRentalId))	

END
