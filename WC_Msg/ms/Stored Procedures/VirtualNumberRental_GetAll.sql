---
-- =============================================
-- History:
-- 2020-03-11	Igor Valyansky	Created
-- =============================================
-- EXEC [ms].[VirtualNumberRental_GetAll]
CREATE PROCEDURE [ms].[VirtualNumberRental_GetAll]
AS
BEGIN

	SELECT
		vn.VNId AS VirtualNumberId,
		vn.VN AS VirtualNumber,
		vn.VNType AS VirtualNumberType,
		vn.Country,
		vn.SMS_ConnUid AS ConnUid,
		r.VnRentalId AS RentalId,		
		r.SubaccountUid,
		r.RentalStart,
		r.RentalEnd
	FROM 
		ms.VirtualNumber vn (NOLOCK)
		LEFT JOIN ms.VirtualNumberRental r (NOLOCK) ON r.VNId = vn.VNId
	WHERE r.VnRentalId IS NULL OR r.RentalEnd > SYSUTCDATETIME()
		
END
