---
-- =============================================
-- History:
-- 2020-03-06	Anton Shchekalov	Created
-- =============================================
-- SELECT TOP 100 * FROM ms.vwVirtualNumberRental
-- =============================================
CREATE VIEW [ms].[vwVirtualNumberRental]
AS
	SELECT
		r.VnRentalId,
		r.VNId,
		vn.VN,
		vn.VNType,
		t.VNTypeName,
		vn.Country,
		vn.SMS_ConnUid AS ConnUid,
		sc.ConnId,
		r.SubaccountUid,
		sa.SubAccountId,
		sa.AccountId,
		sa.AccountUid,
		r.RentalStart,
		r.RentalEnd,
		r.Currency,
		r.MonthlyFee,
		r.SetupFee,
		r.ActivationStatus,
		r.BillingStatus,
		r.ProvisioningStatus,
		r.Address,
		r.UpdatedAt
	FROM 
		ms.VirtualNumberRental r (NOLOCK)
		LEFT JOIN ms.VirtualNumber vn (NOLOCK) ON r.VNId = vn.VNId
		LEFT JOIN ms.vwSubAccount sa (NOLOCK) ON r.SubaccountUid = sa.SubAccountUid
		LEFT JOIN ms.DimVirtualNumberType t ON vn.VNType = t.VNType
		LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = vn.SMS_ConnUid
