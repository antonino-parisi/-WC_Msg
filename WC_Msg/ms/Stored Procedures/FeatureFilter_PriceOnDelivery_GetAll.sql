-- =============================================
-- Author:		Sadeep Madurange
-- Create date: 2020-01-30
-- Description:	Gets all records from FeatureFilter_BillingOnDelivery
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_PriceOnDelivery_GetAll]
AS
    SELECT
		t0.FilterId,
		t0.AccountUid, 
		t0.SubAccountUid,
		t0.Country, 
		t0.OperatorId, 
		t0.Priority, 
		t0.ChargeOnDelivery
	FROM ms.FeatureFilter_PriceOnDelivery t0
    WHERE t0.Enabled = 1;
