
---
-- =============================================
-- History:
-- 2020-04-14	Anton Shchekalov	Created
-- =============================================
-- SELECT TOP 100 * FROM ms.vwVirtualNumber
-- =============================================
CREATE VIEW [ms].[vwVirtualNumber]
AS
	SELECT
		vn.VNId,
		vn.VN,
		vn.VNType,
		t.VNTypeName,
		vn.Country,
		c.CountryName,
		vn.SMS_ConnUid,
		vn.SMS_MTFirst,
		sc.ConnId,
		vn.Product_SMS,
		vn.Product_MMS,
		vn.Product_VO,
		vn.AddressReq,
		vn.UpdatedAt
	FROM 
		ms.VirtualNumber vn (NOLOCK)
		LEFT JOIN mno.Country c ON vn.Country = c.CountryISO2alpha
		LEFT JOIN ms.DimVirtualNumberType t ON vn.VNType = t.VNType
		LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = vn.SMS_ConnUid
