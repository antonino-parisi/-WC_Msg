-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-19
-- Description:	Gets Cost on Delivery config
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_CostOnDelivery_GetAll]
AS
    SELECT
		c.ConfigId,
		c.ConnUid,
		c.OperatorId
	FROM rt.SupplierOperatorConfig c
    WHERE c.ChargeOnDelivery = 1;
